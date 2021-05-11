require("scripts.tracker")
require("scripts.gui")

local function initialize_global(force_name)
    global.forces[force_name] = {}
end

local function clear_global(force_name)
    global.forces[force_name] = nil
end

script.on_nth_tick(120, track_item_creation)

script.on_init(function()
    global.forces = {}

    -- Initialize for existing forces in existing save file
    for _, force in pairs(game.forces) do
        initialize_global(force.name)
    end
end)

script.on_event(defines.events.on_force_created, function(event)
    initialize_global(event.force.name)
end)

script.on_event(defines.events.on_forces_merged, function(event)
    clear_global(event.source_name)
end)
