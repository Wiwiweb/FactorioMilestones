local table = require("__flib__.table")

function initialize_force_if_needed(force)
    if global.forces[force.name] == nil and next(force.players) ~= nil then -- Don't bother with forces without players
        log("Initializing global for force " .. force.name)
        global.forces[force.name] = {
            complete_milestones = {},
            incomplete_milestones = table.deep_copy(global.loaded_milestones)
        }
        backfill_completion_times(force)
    end
end

function initialize_player(player)
    local outer_frame, main_frame, inner_frame = build_main_frame(player)
    global.players[player.index] = {
        outer_frame = outer_frame,
        main_frame = main_frame,
        inner_frame = inner_frame,
        opened_once_before = false,
        pinned = false
    }
end

function clear_force(force_name)
    global.forces[force_name] = nil
end

function clear_player(player_index)
    global.players[player_index] = nil
end
