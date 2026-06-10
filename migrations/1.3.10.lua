log("Running 1.3.10 migration")
-- inner frame GUI changes, we must recreate GUIs
for _, player in pairs(game.players) do
    if storage.players[player.index] then
    reinitialize_player(player.index)
    end
end
