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

log("Running 1.4.1 migration")
reset_storage_flow_statistics()
for force_name, storage_force in pairs(storage.forces) do
    local force = game.forces[force_name]
    if force then
        backfill_completion_times(force)
    end
end
