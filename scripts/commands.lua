
function debug_print_forces()
    game.print(serpent.block(global.forces))
    log(serpent.block(global.forces))
end
commands.add_command("milestones-debug-print-forces", {"milestones.commands.debug-print-forces"}, debug_print_forces)

function debug_print_loaded_milestones()
    game.print(serpent.block(global.loaded_milestones))
    log(serpent.block(global.loaded_milestones))
end
commands.add_command("milestones-debug-print-loaded-milestones", {"milestones.commands.debug-print-loaded-milestones"}, debug_print_loaded_milestones)

function reinitialize_gui(command_data)
    global.players[command_data.player_index].main_frame.destroy()
    local player = game.get_player(command_data.player_index)
    initialize_player(player)
end
commands.add_command("milestones-reinitialize-gui", {"milestones.commands.reinitialize-gui"}, reinitialize_gui)

function reinitialize_global()
    for _, force in pairs(game.forces) do
        initialize_force_if_needed(force)
    end

    for _, player in pairs(game.players) do
        global.players[player.index].main_frame.destroy()
        initialize_player(player)
    end
end
commands.add_command("milestones-reinitialize-global", {"milestones.commands.reinitialize-global"}, reinitialize_global)
