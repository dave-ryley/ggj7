require (data_directory .. ".playerStats")

function spawnPlayer()
	player = display.newGroup()
	playerGraphic = display.newImageRect(player, (players_gfx_directory .. g_player .. ".png"), 170, 170 )
	player.x = 300 
	player.y = dch - 300
	player.stats = playerStats
	return player
end

function spawnButtons()
	buttons = display.newGroup()
	buttons.x, buttons.y = 50, 50
	for i = 1, #currentAbilities do
		buttons[currentAbilities[i]] = display.newText( buttons, currentAbilities[i], 0, 50*(i-1), 300, 50, "Pixeled Regular", 14, "left" )
		buttons[currentAbilities[i]].anchorX = 0
		buttons[currentAbilities[i]]:setTextColor( 0 )
		buttons[currentAbilities[i]].id = currentAbilities[i]
		buttons[currentAbilities[i]].touch = buttonPress
		buttons[currentAbilities[i]]:addEventListener( "touch", buttons[currentAbilities[i]] )
	end
	return buttons
end