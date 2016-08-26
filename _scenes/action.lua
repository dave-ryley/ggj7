local composer = require( "composer" )
local playerBuild = require("playerBuild")
local enemyBuild = require("enemyBuild")
local widget = require("widget")
require ("attacks")
local scene = composer.newScene()

local backdrop
local player
local enemy

-- Temp
local canPress

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
	canPress = true

	-- Creating the attack options panel

	local scrollView = widget.newScrollView
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

	buttons = spawnButtons()
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

	if (phase == "down" and canPress) then
		attack(player, enemy, "basic strike", 1)
	end

	return false
end

local function scrollListener( event )
	local phase = event.phase
	local direction = event.direction

	return true
end

Runtime:addEventListener( "key", onKeyPress )
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
