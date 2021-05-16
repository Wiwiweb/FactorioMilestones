require("scripts.tracker")
require("scripts.gui")

local function initialize_force(force)
    if next(force.players) ~= nil then -- Don't bother with forces without players
        global.forces[force.name] = {
            complete_milestones = {},
            incomplete_milestones = milestones
        }
    end
end

local function initialize_player(player)
    local main_frame, inner_frame = build_main_frame(player)
    global.players[player.index] = {
        main_frame = main_frame,
        inner_frame = inner_frame,
        opened_once_before = false
    }
end

local function clear_force(force_name)
    global.forces[force_name] = nil
end

local function clear_player(player_index)
    global.players[player_index] = nil
end

script.on_init(function()
    global.forces = {}
    global.players = {}

    -- Initialize for existing forces in existing save file
    for _, force in pairs(game.forces) do
        initialize_force(force)
    end
    -- Initialize for existing players in existing save file
    for _, player in pairs(game.players) do
        initialize_player(player)
    end
end)

script.on_event(defines.events.on_force_created, function(event)
    initialize_force(event.force)
end)

script.on_event(defines.events.on_forces_merged, function(event)
    clear_force(event.source_name)
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    initialize_player(player)
end)

script.on_event(defines.events.on_player_removed, function(event)
    clear_player(event.player_index)
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
