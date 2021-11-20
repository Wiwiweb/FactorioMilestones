local table = require("__flib__.table")
require("scripts.global_init")

return {
    ["1.0.4"] = function()
        log("Running 1.0.4 migration")

        -- delayed_chat_message became a table
        if global.delayed_chat_message == nil then
            global.delayed_chat_messages = {}
        else 
            global.delayed_chat_messages = {global.delayed_chat_message}
            global.delayed_chat_message = nil
        end

        -- GUI changed and new outer_table global was added
        for _, player in pairs(game.players) do
            player.gui.screen.clear()
            initialize_player(player)
        end
    end,

    ["1.0.7"] = function()
        log("Running 1.0.7 migration")
        -- 1.0.4 migration contained an error that would affect multiplayer games
        -- Recreate it for all players
        for _, player in pairs(game.players) do
            player.gui.screen.clear()
            initialize_player(player)
        end
    end,

    ["1.0.9"] = function()
        log("Running 1.0.9 migration")
        for force_name, global_force in pairs(global.forces) do
            local affected = false
            for _, milestone in pairs(global_force.complete_milestones) do
                if milestone.type == "technology" and milestone.completion_tick == nil then
                    affected = true
                    milestone.lower_bound_tick = 0
                    milestone.completion_tick = game.tick
                end
            end

            if affected then
                local force = game.forces[force_name]
                force.print("[img=milestones_main_icon_white] If you see this message, you were affected by a Milestones bug which lost the completion time of your [font=default-large-bold]technology[/font] milestones.")
                force.print("The issue is now fixed but you will need to re-enter your lost times in the Milestones window.")
                refresh_gui_for_force(force)
            end
        end
    end,

    ["1.0.10"] = function()
        log("Running 1.0.10 migration")
        -- Editing settings would cause global.loaded_milestones to share objects with global.forces[].*
        -- This could cause global.loaded_milestones to gain completion_tick fields, later messing with initialize_force code
        global.loaded_milestones = table.deep_copy(global.loaded_milestones)
        for _, milestone in pairs(global.loaded_milestones) do
            milestone.completion_tick = nil
            milestone.lower_bound_tick = nil
        end
        for _, global_force in pairs(global.forces) do
            for _, milestone in pairs(global_force.incomplete_milestones) do
                milestone.completion_tick = nil
                milestone.lower_bound_tick = nil
            end
        end
    end,
}
