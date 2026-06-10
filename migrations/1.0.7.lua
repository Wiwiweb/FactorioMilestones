log("Running 1.0.7 migration")
-- 1.0.4 migration contained an error that would affect multiplayer games
-- Recreate it for all players
for _, player in pairs(game.players) do
    player.gui.screen.clear()
    initialize_player(player)
end
