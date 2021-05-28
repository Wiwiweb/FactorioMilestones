local function find_possible_existing_completion_time(global_force, new_milestone)
    for _, complete_milestone in pairs(global_force.complete_milestones) do
        if complete_milestone.type == new_milestone.type and
           complete_milestone.name == new_milestone.name and
           complete_milestone.quantity == new_milestone.quantity then
            return complete_milestone.completion_tick
        end
    end
    return nil
end

function merge_new_milestones(global_force, new_milestones)
    local new_complete = {}
    local new_incomplete = {}

    for _, new_milestone in pairs(new_milestones) do
        local completion_tick = find_possible_existing_completion_time(global_force, new_milestone)
        if completion_tick == nil then
            table.insert(new_incomplete, new_milestone)
        else
            new_milestone.completion_tick = completion_tick
            table.insert(new_complete, new_milestone)
        end
    end

    global_force.complete_milestones = new_complete
    global_force.incomplete_milestones = new_incomplete
end

function mark_milestone_reached(force, milestone, milestone_index, before) -- before is optional
    milestone.completion_tick = game.tick
    if before then milestone.before = true end
    table.insert(global.forces[force.name].complete_milestones, milestone)
    table.remove(global.forces[force.name].incomplete_milestones, milestone_index)
end

function backfill_completion_times(force)
    local item_counts = force.item_production_statistics.input_counts
    local fluid_counts = force.fluid_production_statistics.input_counts
    local technologies_researched = force.technologies
    
    local global_force = global.forces[force.name]
    for i, milestone in ipairs(global_force.incomplete_milestones) do
        if is_milestone_reached(force, milestone, item_counts, fluid_counts, technologies_researched) then
            mark_milestone_reached(force, milestone, i, true)
        end
    end
end


function is_production_milestone_reached(force, milestone, item_counts, fluid_counts)
    local type_count = milestone.type == "item" and item_counts or fluid_counts
    local milestone_count = type_count[milestone.name]
    if milestone_count ~= nil and milestone_count >= milestone.quantity then
        return true
    end
    return false
end

function is_tech_milestone_reached(force, milestone, technology_researched)
    local level_needed = milestone.quantity == 1 and 1 or (milestone.quantity + 1) -- +1 because the level we get is the current researchable level, not the researched level
    if milestone.type == "technology" and
       technology_researched.name == milestone.name and
       technology_researched.level >= level_needed then
        return true
    end
    return false
end

function is_milestone_reached(force, milestone, item_counts, fluid_counts, technologies_researched)
    if milestone.type == "technology" then
        local technology_researched = technologies_researched[milestone.name]
        return is_tech_milestone_reached(force, milestone, technology_researched)
    else
        return is_production_milestone_reached(force, milestone, item_counts, fluid_counts)
    end
end
