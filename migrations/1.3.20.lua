function reset_storage_flow_statistics()
  for force_name, storage_force in pairs(storage.forces) do
    local force = game.forces[force_name]
    if force then
      storage_force.item_stats = {}
      storage_force.fluid_stats = {}
      storage_force.kill_stats = {}
      add_flow_statistics_to_storage_force(force)
    end
  end
end

log("Running 1.3.20 migration")
-- Recalculate the sort_index of infinite milestones (first is n, second is n.0001, third is n.0002, etc.)
reset_storage_flow_statistics()
for force_name, force in pairs(game.forces) do
    if storage.forces[force_name] ~= nil then
        merge_new_milestones(force_name, storage.loaded_milestones)
        backfill_completion_times(force)
    end
end
