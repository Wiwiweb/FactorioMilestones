log("Running 1.0.4 migration")

-- delayed_chat_message became a table
if storage.delayed_chat_message == nil then
    storage.delayed_chat_messages = {}
else
    storage.delayed_chat_messages = { storage.delayed_chat_message }
    storage.delayed_chat_message = nil
end

-- GUI changed and new outer_table global was added
for _, player in pairs(game.players) do
    player.gui.screen.clear()
    initialize_player(player)
end
