log("Running 1.0.10 migration")
-- Editing settings would cause storage.loaded_milestones to share objects with storage.forces[].*
-- This could cause storage.loaded_milestones to gain completion_tick fields, later messing with initialize_force code
storage.loaded_milestones = table.deep_copy(storage.loaded_milestones)
for _, milestone in pairs(storage.loaded_milestones) do
    milestone.completion_tick = nil
    milestone.lower_bound_tick = nil
end
for _, storage_force in pairs(storage.forces) do
    for _, milestone in pairs(storage_force.incomplete_milestones) do
    milestone.completion_tick = nil
    milestone.lower_bound_tick = nil
    end
end
