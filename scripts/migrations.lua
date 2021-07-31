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
            global.players[player.index].main_frame.destroy()
            global.players = {}
            initialize_player(player)
        end
    end
}
