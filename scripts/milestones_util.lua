local table = require("__flib__.table")

-- Each production graph bracket, from highest to lowest, with associated frame count
-- Used in find_higher_bound_production_tick()
local FLOW_PRECISION_BRACKETS = {
    {defines.flow_precision_index.one_thousand_hours,      1000*60*60*60},
    {defines.flow_precision_index.two_hundred_fifty_hours, 250*60*60*60},
    {defines.flow_precision_index.fifty_hours,             50*60*60*60},
    {defines.flow_precision_index.ten_hours,               10*60*60*60},
    {defines.flow_precision_index.one_hour,                1*60*60*60},
    {defines.flow_precision_index.ten_minutes,             10*60*60},
    {defines.flow_precision_index.one_minute,              1*60*60},
    {defines.flow_precision_index.five_seconds,            5*60},
}

local function find_possible_existing_completion_time(global_force, new_milestone)
    for _, complete_milestone in pairs(global_force.complete_milestones) do
        if complete_milestone.type == new_milestone.type and
           complete_milestone.name == new_milestone.name and
           complete_milestone.quantity == new_milestone.quantity then
            return complete_milestone.completion_tick, complete_milestone.lower_bound_tick
        end
    end
    return nil, nil
end

function merge_new_milestones(global_force, new_milestones)
    local new_complete = {}
    local new_incomplete = {}

    for _, new_milestone in pairs(new_milestones) do
        local completion_tick, lower_bound_tick = find_possible_existing_completion_time(global_force, new_milestone)
        if completion_tick == nil then
            table.insert(new_incomplete, new_milestone)
        else
            new_milestone.completion_tick = completion_tick
            new_milestone.lower_bound_tick = lower_bound_tick
            table.insert(new_complete, new_milestone)
        end
    end

    global_force.complete_milestones = table.deep_copy(new_complete)
    global_force.incomplete_milestones = table.deep_copy(new_incomplete)
end

function get_default_unit_for_time_bucket(lower_bound_tick, upper_bound_tick)
    local lower_bound_ticks_ago = game.tick - lower_bound_tick - 10*60*60 -- Add 10 minutes leeway to avoid bumping something to the next unit 1 tick after we calculate it
    local upper_bound_ticks_ago = game.tick - upper_bound_tick
    local upper_bound_minutes_ago = upper_bound_ticks_ago / 60 / 60

    if lower_bound_ticks_ago <= 1*60*60*60 then -- 1 hour ago
        return 1, upper_bound_minutes_ago -- minutes
    elseif lower_bound_ticks_ago < 50*60*60*60 then -- 50 hours ago
        return 2, upper_bound_minutes_ago / 60 -- hours
    else -- More than 50 hours ago
        return 3, upper_bound_minutes_ago / 60 / 24 -- days
    end
end

function mark_milestone_reached(force, milestone, tick, milestone_index, lower_bound_tick) -- lower_bound_tick is optional
    milestone.completion_tick = tick
    if lower_bound_tick then milestone.lower_bound_tick = lower_bound_tick end
    table.insert(global.forces[force.name].complete_milestones, milestone)
    table.remove(global.forces[force.name].incomplete_milestones, milestone_index)
end

function floor_to_nearest_minute(tick)
    return (tick - (tick % (60*60)))
end

function ceil_to_nearest_minute(tick)
    return (tick - (tick % (60*60))) + 60*60
end

-- Converts from "X ticks ago" to "X ticks since start of the game"
local function get_realtime_tick_bounds(lower_bound_ticks_ago, upper_bound_ticks_ago)
    return math.max(0, floor_to_nearest_minute(game.tick - lower_bound_ticks_ago)), ceil_to_nearest_minute(game.tick - upper_bound_ticks_ago)
end

local function find_production_tick_bounds(force, milestone, stats)
    local total_count = stats.get_input_count(milestone.name)
    local lower_bound_ticks_ago = game.tick
    for _, flow_precision_bracket in pairs(FLOW_PRECISION_BRACKETS) do
        local bracket, upper_bound_ticks_ago = flow_precision_bracket[1], flow_precision_bracket[2]
        log("up: " ..upper_bound_ticks_ago.. " - low: " ..lower_bound_ticks_ago)
        -- The first bracket that does NOT match the total count indicates the upper bound first production time
        -- e.g: if total_count = 4, 4 were created in the last 1000 hours, 4 were created in the last 500 hours, 3 were created in the last 250 hours
        -- then the first creation was before 250 hours ago
        if upper_bound_ticks_ago < game.tick then -- Skip brackets if the game is not long enough
            local bracket_count = stats.get_flow_count{name=milestone.name, input=true, precision_index=bracket, count=true}
            if bracket_count <= total_count - milestone.quantity then
                return get_realtime_tick_bounds(lower_bound_ticks_ago, upper_bound_ticks_ago)
            end
        end
        lower_bound_ticks_ago = upper_bound_ticks_ago
    end
    -- If we haven't found any count drop after going through all brackets
    -- then the item was produced within the last 5 seconds (improbable but could happen)
    return get_realtime_tick_bounds(lower_bound_ticks_ago, game.tick)
end


local function find_completion_tick_bounds(force, milestone, item_stats, fluid_stats)
    if milestone.type == "technology" then
        return 0, game.tick -- No way to know past research time
    elseif milestone.type == "item" then
        return find_production_tick_bounds(force, milestone, item_stats)
    elseif milestone.type == "fluid" then
        return find_production_tick_bounds(force, milestone, fluid_stats)
    end
end

function sort_milestones(milestones)
    table.sort(milestones, function(a,b) 
        return a.completion_tick < b.completion_tick 
    end)
end

function backfill_completion_times(force)
    log("Backfilling completion times for " .. force.name)
    local item_stats = force.item_production_statistics
    local fluid_stats = force.fluid_production_statistics
    local item_counts = item_stats.input_counts
    local fluid_counts = fluid_stats.input_counts
    local technologies = force.technologies

    local global_force = global.forces[force.name]
    local i = 1
    while i <= #global_force.incomplete_milestones do
        local milestone = global_force.incomplete_milestones[i]
        if is_milestone_reached(force, milestone, item_counts, fluid_counts, technologies) then
            local lower_bound, upper_bound = find_completion_tick_bounds(force, milestone, item_stats, fluid_stats)
            log("Tick bounds for " ..milestone.name.. " : " ..lower_bound.. " - " ..upper_bound)
            mark_milestone_reached(force, milestone, upper_bound, i, lower_bound)
        else
            i = i + 1
        end
    end
    sort_milestones(global_force.complete_milestones)
end

function is_production_milestone_reached(force, milestone, item_counts, fluid_counts)
    local type_count = milestone.type == "item" and item_counts or fluid_counts
    local milestone_count = type_count[milestone.name]
    if milestone_count ~= nil and milestone_count >= milestone.quantity then
        return true
    end
    return false
end

function is_tech_milestone_reached(force, milestone, technology)
    if milestone.type == "technology" and
       technology.name == milestone.name and
       -- strict > because the level we get is the current researchable level, not the researched level
       (technology.researched or technology.level > milestone.quantity) then
        return true
    end
    return false
end

function is_milestone_reached(force, milestone, item_counts, fluid_counts, technologies)
    if milestone.type == "technology" then
        local technology = technologies[milestone.name]
        return is_tech_milestone_reached(force, milestone, technology)
    else
        return is_production_milestone_reached(force, milestone, item_counts, fluid_counts)
    end
end
