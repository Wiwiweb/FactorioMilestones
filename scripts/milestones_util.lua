local function find_possible_existing_completion_time(global_force, new_milestone)
    for _, completed_milestone in pairs(global_force.complete_milestones) do
        if completed_milestone.type == new_milestone.type and
           completed_milestone.name == new_milestone.name and
           completed_milestone.quantity == new_milestone.quantity then
            return completed_milestone.completion_tick
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

local function check_milestone_reached(global_force, milestone, stats, milestone_index)
    if stats.get_input_count(milestone.name) >= milestone.quantity then
        milestone.completion_tick = game.tick
        table.insert(global.forces[force.name].complete_milestones, milestone)
        table.remove(global.forces[force.name].incomplete_milestones, milestone_index)
        print_milestone_reached(force, milestone)
        for _, player in pairs(force.players) do
            refresh_gui(player)
        end
            
    end
end

function backfill_completion_times(global_force)
    -- TODO
end