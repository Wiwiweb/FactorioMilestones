-- Reset pin button, its icon changed
for _, player in pairs(game.players) do
    local storage_player = storage.players[player.index]
    if storage_player then
        local pinned = storage_player.pinned
        local outer_frame = storage_player.outer_frame
        if outer_frame.valid then
            outer_frame.destroy()
            initialize_player(player)
        end
        storage.players[player.index].pinned = pinned
    end
end
