log("Running 1.0.9 migration")
for force_name, storage_force in pairs(storage.forces) do
    local affected = false
    for _, milestone in pairs(storage_force.complete_milestones) do
    if milestone.type == "technology" and milestone.completion_tick ==
        nil then
        affected = true
        milestone.lower_bound_tick = 0
        milestone.completion_tick = game.tick
    end
    end

    if affected then
    local force = game.forces[force_name]
    force.print(
        "[img=milestones_main_icon_white] If you see this message, you were affected by a Milestones bug which lost the completion time of your [font=default-large-bold]technology[/font] milestones.")
    force.print(
        "The issue is now fixed but you will need to re-enter your lost times in the Milestones window.")
    refresh_gui_for_force(force)
    end
end
