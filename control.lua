require("scripts.tracker")
require("scripts.gui")

local function initialize_global(force)
    if next(force.players) ~= nil then -- Don't bother with forces without players
        global.forces[force.name] = {
            complete_milestones = {},
            incomplete_milestones = milestones
        }
    end
end

local function clear_global(force_name)
    global.forces[force_name] = nil
end

script.on_init(function()
    global.forces = {}

    -- Initialize for existing forces in existing save file
    for _, force in pairs(game.forces) do
        initialize_global(force)
    end
end)

script.on_event(defines.events.on_force_created, function(event)
    initialize_global(event.force)
end)

script.on_event(defines.events.on_forces_merged, function(event)
    clear_global(event.source_name)
end)

script.on_nth_tick(settings.global["milestones_check_frequency"].value, track_item_creation)
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting == "milestones_check_frequency" then
        script.on_nth_tick(nil) -- Unregister event
        script.on_nth_tick(settings.global["milestones_check_frequency"].value, track_item_creation)
    end
end)

-- Debug command
remote.add_interface("milestones", {
    debug_print_milestones = function()
        game.print(serpent.block(global.forces))
    end
})
