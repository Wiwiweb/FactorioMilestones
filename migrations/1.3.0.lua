log("Running 1.3.0 migration")
for force_name, storage_force in pairs(storage.forces) do
    -- Add new milestones_by_group field, but just put all existing milestones in the Other group
    storage_force.milestones_by_group = { ["Other"] = {} }
    for i, milestone in pairs(storage_force.complete_milestones) do
    milestone.sort_index = i
    milestone.group = "Other"
    table.insert(storage_force.milestones_by_group["Other"], milestone)
    end
    for i, milestone in pairs(storage_force.incomplete_milestones) do
    milestone.sort_index = i
    milestone.group = "Other"
    table.insert(storage_force.milestones_by_group["Other"], milestone)
    end

    -- Update old estimations with new more accurate estimations
    local force = game.forces[force_name]
    local item_stats = force.item_production_statistics
    local fluid_stats = force.fluid_production_statistics
    local kill_stats = force.kill_count_statistics
    for _, milestone in pairs(storage_force.complete_milestones) do
    if is_valid_milestone(milestone) and milestone.lower_bound_tick ~= nil then
        local new_lower_bound, new_upper_bound = find_completion_tick_bounds(milestone, item_stats, fluid_stats,
        kill_stats)
        log("Old tick bounds for " ..
        milestone.name .. " : " .. milestone.lower_bound_tick .. " - " .. milestone.completion_tick)
        log("New tick bounds for " .. milestone.name .. " : " .. new_lower_bound .. " - " .. new_upper_bound)
        milestone.lower_bound_tick = math.max(milestone.lower_bound_tick, new_lower_bound)
        milestone.completion_tick = math.min(milestone.completion_tick, new_upper_bound)
    end
    end
end
