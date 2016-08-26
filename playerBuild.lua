require (data_directory .. ".playerStats")
function spawnPlayer()
	player = display.newGroup()
	playerGraphic = display.newImageRect(player, (players_gfx_directory .. g_player .. ".png"), 170, 170 )
	player.x = 300 
	player.y = dch - 300
	player.stats = playerStats
	return player
end
