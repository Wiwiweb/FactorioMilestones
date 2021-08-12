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
}
