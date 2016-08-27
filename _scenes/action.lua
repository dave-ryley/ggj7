local composer = require( "composer" )
local playerBuild = require("playerBuild")
local enemyBuild = require("enemyBuild")
local widget = require("widget")
require ("attacks")
require ("_data.attackTypes")
local scene = composer.newScene()

local backdrop
local player
local enemy
local scrollView
local at_options
local announcementText
local currentTurn

-- "scene:create()"
function scene:create( event )
	local sceneGroup = self.view
	-- set the background based on the background set in globals
	backdrop = display.newImageRect((backdrops_gfx_directory .. g_backdrop .. ".jpg"), 1280, 720 )
	player = spawnPlayer()
	enemy = spawnEnemy()
	playerHealth = makeHealthBar(0, g_playerName)
	enemyHealth = makeHealthBar(1, g_enemy)
	backdrop.x = dccx
	backdrop.y = dccy
	currentTurn = "player"

	at_options = {
		text = "",
		font = "VCR OSD Mono",
		fontSize = 50,
		width = 1000,
		align = "center",
		x = dccx,
		y = dccy - 100,
	}

	announcementText = create_shadowed_text( at_options )

	-- Creating the attack options panel

	scrollView = widget.newScrollView
	{
		left = 70,
		top = 70,
		width = 500,
		height = 200,
		topPadding = 20,
		bottomPadding = 20,
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = scrollListener,
	}

	local buttons = spawnButtons()
	scrollView:insert(buttons)

end

-- "scene:show()"
function scene:show( event )

	local sceneGroup = self.view
	--startTimer = timer.performWithDelay( 500, blink, 0 )

	if ( phase == "will" ) then
	-- Called when the scene is still off screen (but is about to come on screen).
	-- Add all physics objects

	elseif ( phase == "did" ) then
	-- Called when the scene is now on screen.
	-- Insert code here to make the scene come alive.
	-- Example: start timers, begin animation, play audio, etc.

	end
end

-- "scene:hide()"
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	-- Called when the scene is on screen (but is about to go off screen).
	-- Insert code here to "pause" the scene.
	-- Example: stop timers, stop animation, stop audio, etc.
	elseif ( phase == "did" ) then
	-- Called immediately after scene goes off screen.
	end
end

-- "scene:destroy()"
function scene:destroy( event )

	local sceneGroup = self.view
-- Called prior to the removal of scene's view ("sceneGroup").
-- Insert code here to clean up the scene.
-- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

local function onKeyPress( event )
	local phase = event.phase
	local keyName = event.keyName

	if (phase == "down") then
		attack(player, enemy, "basic strike", 1)
	end

	return false
end

local function scrollListener( event )
	local phase = event.phase
	local direction = event.direction

	return true
end

function buttonPress( self, event )
	if event.phase == "began" then
		playerTurn(self.id)
		return true
	end
end

function playerTurn( id )
	transition.to( scrollView, {
		time = 400,
		y = -300,
		delta = true,
		onComplete = function()
			calculateDamage(id, "player")
			announceAttack(g_playerName, id)
			attack(player, enemy, id, 1)
		end} )
	timer.performWithDelay( 1000, endTurn )
end

function enemyTurn()
	announceAttack(g_enemy, enemy.strategy[enemy.currentAttack])
	calculateDamage(enemy.strategy[enemy.currentAttack], "enemy")
	attack(enemy, player, enemy.strategy[enemy.currentAttack], -1)
	enemy.currentAttack = enemy.currentAttack + 1
	if (enemy.currentAttack > #enemy.strategy) then
		enemy.currentAttack = 1
	end
	timer.performWithDelay( 1000, endTurn )
end

function calculateDamage(id, attacker)
	local roll = math.random(20)
	if attacker == "player" then
		local damage = attackTypes[id].damage*player.stats.attack*roll/20
		enemy.stats.health = enemy.stats.health - damage
	else
		local damage = attackTypes[id].damage*enemy.stats.attack*roll/20
		player.stats.health = player.stats.health - damage
	end
	print(roll,damage)
end

function endTurn()
	announcementText:setText("")
	transition.scaleTo( playerHealth.bar, { xScale=player.stats.health/player.stats.maxHealth, yScale=1, time=200 } )
	transition.scaleTo( enemyHealth.bar, { xScale=enemy.stats.health/enemy.stats.maxHealth, yScale=1, time=200 } )
	if(currentTurn == "player") then
		currentTurn = "enemy"
		timer.performWithDelay( 1000, enemyTurn )
	else
		currentTurn = "player"
		transition.to( scrollView, {
		time = 400,
		y = 300,
		delta = true } )
	end
end

function announceAttack( name, id )
	announcementText:setText(name .. " used " .. id)
end


--Runtime:addEventListener( "key", onKeyPress )
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
