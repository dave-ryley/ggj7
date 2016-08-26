require (data_directory .. ".enemyStats")
function spawnEnemy()
	enemy = display.newGroup()
	enemyGraphic = display.newImageRect(enemy, (enemies_gfx_directory .. g_enemy .. ".png"), 170, 170 )
	enemy.x = dcw - 300 
	enemy.y = dch - 300
	enemy.stats = enemyStats[g_enemy]
	return enemy
end

-- Function to make a health bar. 
-- If input is 0, it makes a health bar for the player, if input is 1 it makes an enemy health bar

function makeHealthBar( playerOrEnemy, name )
	healthBar = display.newGroup()
	healthBar.anchorX = playerOrEnemy
	hb_bg = display.newImageRect( healthBar, (gfx_directory .. "/action/healthbar" .. playerOrEnemy .. ".png"), 340, 100 )
	hb_bg.anchorX = playerOrEnemy
	options = {}
	name = display.newText( healthBar, name, 0, -20, 100, 50, "Pixeled Regular", 14, "left" )
	name.anchorX = playerOrEnemy
	bar = display.newRect( healthBar, 0, 0, 300, 50 )
	bar:setFillColor( 0, 1, 0 )
	bar.anchorX = playerOrEnemy
	if (playerOrEnemy == 1) then
		name.align = "right"
		bar.x, name.x = -20, -20
		healthBar.x = dcw - 50
	else
		bar.x, name.x = 20, 20
		healthBar.x = 50
	end
	bar.y = 10
	healthBar.y = dch - 100
	healthBar.anchorY = 1
	return healthBar
end