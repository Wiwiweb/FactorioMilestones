log("Running 1.3.14 migration")
-- Caching some calculations for optimisation
storage.milestones_check_frequency_setting = settings.global["milestones_check_frequency"].value
for force_name, storage_force in pairs(storage.forces) do
    local force = game.forces[force_name]
    storage_force.item_stats = force.item_production_statistics
    storage_force.fluid_stats = force.fluid_production_statistics
    storage_force.kill_stats = force.kill_count_statistics
end
