log("Running 1.2.1 migration")
-- Table reference error could have introduced completion times in storage.loaded_milestones during merge_new_milestones
storage.loaded_milestones = table.deep_copy(storage.loaded_milestones)
for _, milestone in pairs(storage.loaded_milestones) do
    milestone.completion_tick = nil
    milestone.lower_bound_tick = nil
end
