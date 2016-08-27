local composer = require "composer"
local widget = require "widget"
local scene = composer.newScene()
local scale = 2
local players = require (data_directory .. ".playerStats")
local bg_num = 1
local selected_bg = 1
--local padding = math.round((svw - tiles.width * scale) / 2)
--local button_size = 170 * scale + padding * 2
local button_size = 170
local svw = button_size
local selected_string = ""
local selection = 1
local moved = false
local numPlayers = 3
local selected_character = nil
local selection_rect = nil
local players_display = nil
local selected_display = nil
local stat_display = nil

local scrollView = nil
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function selectBackground()
	local sdcw = selected_display.contentWidth
	local sdch = selected_display.contentHeight
	selected_display.x = button_size
	local background = display.newImageRect(
			(backdrops_gfx_directory .. "background".. selected_bg .. ".jpg"), 
			sdcw*1.5, sdch*1.5 --[[*3/4--]])
	background.x = sdcw/2
	background.y = sdch*3/8 --[[/2--]]
	selected_display:insert( 1, background )
end


local function handleButtonLeft( event )

    if ( "ended" == event.phase ) then
		if selected_bg > 1 then
			selected_bg = selected_bg - 1
			selected_display[1]:removeSelf( )
			selectBackground()
		end
    end
end

local function handleButtonRight( event )
	if ( "ended" == event.phase ) then
		if selected_bg < g_total_backdrops then
			selected_bg = selected_bg + 1
			selected_display[1]:removeSelf( )
			selectBackground()
		end
	end
end

local function handleButtonGo( event )
	if ( "ended" == event.phase ) then
		print( "Button was pressed and released" )
		g_player = "player"..selection
		g_player_number = selection
		g_backdrop = selected_bg
		composer.gotoScene( scenes_directory .. ".action")
	end
end

local function handleTabBarEvent(event)
	print("tabbar: "..event.target.id)
	if event.target.id == "tab1" then
		createStatBox()
	else
		createAbilityBox()
	end
end

local function init()
	selected_display = display.newGroup( )
	players_display = display.newGroup( )
	stat_display = display.newGroup( )
	selection_rect = display.newRect( -500, -500, button_size, button_size )
end

local function selectPlayer(event)
	if event then
		local x, y = event.target:getContentPosition()
		selection = math.ceil((event.y - y)/button_size)
	end
	
	--print(tiles_list[selection].name)
	if selection <= numPlayers then
		if selected_character then
			selected_character:removeSelf( )
			players_display[players_display.numChildren]:removeSelf( )
		end

		local selection_outline = display.newLine( 	2, (selection - 1) * button_size,
											button_size - 3, (selection - 1) * button_size,
											button_size - 3, selection * button_size,
											2, selection * button_size,
											2, (selection - 1) * button_size)

		selection_outline.strokeWidth = 3
		selection_outline:setStrokeColor( 1, 0, 0 )
		players_display:insert(players_display.numChildren + 1, selection_outline)
		selected_string = players_gfx_directory.."player"..selection..".png"
		--Display large selected character sprite/animation
		selected_character = display.newImage( 		
			selected_string, 
			selected_display.contentWidth*2/11, 
			selected_display.contentHeight*6/8 )
		selected_display:insert( selected_character)
		createStatBox()
		selected_character:scale(1.5, 1.5)
	end
end

local function scrollListener( event )
	local phase = event.phase
	print(moved)
	if phase == "moved" then
		moved = true
	end
	if ( phase == "ended") then
		if not moved then

			selectPlayer(event)

		end

		moved = false
	end
	return true
end


local function createButtons()
	local go_button = widget.newButton(
		{
			width =  300,
			height = 100,
			defaultFile = ui_gfx_directory.."buttons/go_button1.png",
			overFile = ui_gfx_directory.."buttons/go_button2.png",
			label = "",
			onEvent = handleButtonGo
		}
	)
	go_button.x = selected_display.contentWidth*3/7
	go_button.y = selected_display.contentHeight*6/7
	selected_display:insert(go_button)

	local left_button = widget.newButton(
		{
			width =  200,
			height = 75,
			defaultFile = ui_gfx_directory.."buttons/left_button1.png",
			overFile = ui_gfx_directory.."buttons/left_button2.png",
			label = "",
			onEvent = handleButtonLeft
		}
	)
	left_button.x = selected_display.contentWidth*3/8
	left_button.y = selected_display.contentHeight/8
	selected_display:insert(left_button)

	local right_button = widget.newButton(
		{
			width =  200,
			height = 75,
			defaultFile = ui_gfx_directory.."buttons/right_button1.png",
			overFile = ui_gfx_directory.."buttons/right_button2.png",
			label = "",
			onEvent = handleButtonRight
		}
	)
	right_button.x = selected_display.contentWidth*5/8
	right_button.y = selected_display.contentHeight/8
	selected_display:insert( right_button)
end

local function createScrollView()
	scrollView = widget.newScrollView(
		{
			top = 0,
			left = 0,
			width = svw,
			height = dch,
			scrollWidth = 0,
			listener = scrollListener,
			verticleScrollDisabled = false,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
			hideScrollBar = false
		}
	)
	local start = 0
	for i=1, numPlayers do

		local p = display.newImage(players_gfx_directory.."player"..i..".png", button_size/2, start + button_size/2 )
		--p:scale( scale, scale )
		start = start + button_size
		players_display:insert( p )
		print("start: ".. start)
	end
	players_display:insert( selection_rect )
	scrollView:insert(players_display)
	scrollView:setScrollHeight( start )

end



local function createSelectedDisplay()
	selected_display.contentWidth = dcw - button_size
	selected_display.contentHeight = dch
	--[[
	local tabButtons = {
		{
			label = "Stats",
			id = "tab1",
			selected = true,
			onPress = handleTabBarEvent
		},
		{
			label = "Abilities",
			id = "tab2",
			onPress = handleTabBarEvent
		}

	}

	-- Create the widget
	local tabBar = widget.newTabBar(
	    {
	        top = display.contentHeight-120,
	        width = 300,
	        buttons = tabButtons
	    }
	)
	tabBar.x = 500
	tabBar.y = 300
	--]]
	selectBackground()
end

function createAbilityBox()
	stat_display:removeSelf( )
	stat_display = display.newGroup( )
	local abilities = players[selection].currentAbilities
	for i=1, #abilities do
		display.newText( stat_display, abilities[i], 0, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
	end
	stat_display.x = selected_display.contentWidth*5/7
	stat_display.y = selected_display.contentHeight*9/11
	selected_display:insert( stat_display )
end

function createStatBox()
	stat_display:removeSelf( )
	stat_display = display.newGroup( )
	local stats = players[selection].playerStats
	local i= 0

	--[[
	for k, v in pairs(stats) do
		print("here")
		display.newText( stat_display, k..":", 0, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
		display.newText( stat_display, v, 150, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
		i = i + 1
	end

	--]]
	--display health
	display.newText( stat_display, "Health:", 0, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
	display.newText( stat_display, stats.maxHealth, 150, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
	i = i + 1
	--display attack
	display.newText( stat_display, "Attack:", 0, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
	display.newText( stat_display, stats.attack, 150, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
	i = i + 1
	--display defense
	display.newText( stat_display, "Defense:", 0, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
	display.newText( stat_display, stats.defense, 150, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
	i = i + 1
	--display dodge
	display.newText( stat_display, "Dodge:", 0, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
	display.newText( stat_display, stats.dodgeChance, 150, 20*(i), 300, 50, "Pixeled.ttf", 14, "left" )
	i = i + 1

	stat_display.x = selected_display.contentWidth*5/7
	stat_display.y = selected_display.contentHeight*9/11
	selected_display:insert( stat_display )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        init()
        createSelectedDisplay()
        createScrollView()
        createButtons()
        selectPlayer()
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		selected_display:removeSelf( )
		players_display:removeSelf( )
		scrollView:removeSelf( )
		scene:destroy()
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
