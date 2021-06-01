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
            return complete_milestone.completion_tick, complete_milestone.before
        end
    end
    return nil, nil
end

function merge_new_milestones(global_force, new_milestones)
    local new_complete = {}
    local new_incomplete = {}

    for _, new_milestone in pairs(new_milestones) do
        local completion_tick, before = find_possible_existing_completion_time(global_force, new_milestone)
        if completion_tick == nil then
            table.insert(new_incomplete, new_milestone)
        else
            new_milestone.completion_tick = completion_tick
            new_milestone.before = before
            table.insert(new_complete, new_milestone)
        end
    end

    global_force.complete_milestones = new_complete
    global_force.incomplete_milestones = new_incomplete
end

function mark_milestone_reached(force, milestone, tick, milestone_index, before) -- before is optional
    milestone.completion_tick = tick
    if before then milestone.before = true end
    table.insert(global.forces[force.name].complete_milestones, milestone)
    table.remove(global.forces[force.name].incomplete_milestones, milestone_index)
end

local function ceil_to_nearest_minute(tick)
    return (tick - (tick % (60*60))) + 60*60
end

local function find_higher_bound_production_tick(force, milestone, stats)
    local total_count = stats.get_input_count(milestone.name)
    for _, flow_precision_bracket in pairs(FLOW_PRECISION_BRACKETS) do
        local bracket, bracket_ticks = flow_precision_bracket[1], flow_precision_bracket[2]
        -- The first bracket that does NOT match the total count indicates the higher bound first production time
        -- e.g: if total_count = 4, 4 were created in the last 1000 hours, 4 were created in the last 500 hours, 3 were created in the last 250 hours
        -- then the first creation was before 250 hours ago
        if bracket_ticks < game.tick then -- Skip brackets if the game is not long enough
            local bracket_count = stats.get_flow_count{name=milestone.name, input=true, precision_index=bracket, count=true}
            if bracket_count <= total_count - milestone.quantity then
                return ceil_to_nearest_minute(game.tick - bracket_ticks) 
            end
        end
    end
    -- If we haven't found any count drop after going through all brackets
    -- then the item was produced within the last 5 seconds (improbable but could happen)
    return ceil_to_nearest_minute(game.tick)
end


local function find_higher_bound_completion_tick(force, milestone, item_stats, fluid_stats)
    if milestone.type == "technology" then
        return game.tick -- No way to know past research time
    elseif milestone.type == "item" then
        return find_higher_bound_production_tick(force, milestone, item_stats)
    elseif milestone.type == "fluid" then
        return find_higher_bound_production_tick(force, milestone, fluid_stats)
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
            local tick = find_higher_bound_completion_tick(force, milestone, item_stats, fluid_stats)
            mark_milestone_reached(force, milestone, tick, i, true)
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
