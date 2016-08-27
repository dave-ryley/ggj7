local composer = require "composer"
local widget = require "widget"
local scene = composer.newScene()
local scale = 2
local players = require (data_directory .. ".playerStats")

--local padding = math.round((svw - tiles.width * scale) / 2)
local players_display = display.newGroup( )
--local button_size = 170 * scale + padding * 2
local button_size = 170
local svw = button_size
local selection_rect = display.newRect( -500, -500, button_size, button_size )
local selected_string = ""
local selection = 1
local moved = false
local numPlayers = 2
local selected_display = display.newGroup( )
local stat_display = display.newGroup( )
local scrollView = nil

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
        print( "Button was pressed and released" )
        g_player = "player"..selection
        g_player_number = selection
        composer.gotoScene( scenes_directory .. ".action")
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
			local x, y = event.target:getContentPosition()

			selection = math.ceil((event.y - y)/button_size)
			--print(tiles_list[selection].name)
			if selection <= numPlayers then
				if selected_display.numChildren > 2 then
					selected_display[3]:removeSelf( )
				end
				players_display[players_display.numChildren]:removeSelf( );

				local selection_outline = display.newLine( 	2, (selection - 1) * button_size,
													button_size - 3, (selection - 1) * button_size,
													button_size - 3, selection * button_size,
													2, selection * button_size,
													2, (selection - 1) * button_size)

				selection_outline.strokeWidth = 3
				selection_outline:setStrokeColor( 1, 0, 0 )
				players_display:insert(selection_outline)
				selected_string = players_gfx_directory.."player"..selection..".png"
				--Display large selected character sprite/animation
				local s = display.newImage( 		
					selected_string, 
					selected_display.contentWidth/4, 
					selected_display.contentHeight/2 )
				selected_display:insert(3, s)
				s:scale(2, 2)
				createStatBox()
			end
			
		end
		
		moved = false
	end
	return true
end


local function createButton()
	local go_button = widget.newButton( 	
		{
			width =  315,
			height = 116,
			defaultFile = ui_gfx_directory.."buttons/go_button1.png",
			overFile = ui_gfx_directory.."buttons/go_button2.png",
			label = "GO",
			onEvent = handleButtonEvent
		}
	)
	go_button.x = dcw/2
	go_button.y = dch*5/6
	selected_display:insert(2, go_button)
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
	players_display:insert( selection_rect)
	scrollView:insert(players_display)
	scrollView:setScrollHeight( start )

end

function createSelectedDisplay()
	selected_display.contentWidth = dcw - button_size
	selected_display.contentHeight = dch
	selected_display.x = button_size
	local background = display.newRect( dcw/2, dch/2, dcw, dch )
	background:setFillColor( 0.5 )
	selected_display:insert( 1, background )
end


function createStatBox()
	stat_display:removeSelf( )
	stat_display = display.newGroup( )
	local stats = players[selection].playerStats
	local i= 0
	for k, v in pairs(stats) do
		print("here")
		display.newText( stat_display, k..":", 0, 20*(i), 300, 50, "Pixeled Regular", 14, "left" )
		display.newText( stat_display, v, 100, 20*(i), 300, 50, "Pixeled Regular", 14, "left" )
		i = i + 1
	end
	stat_display.x = selected_display.contentWidth*3/4
	stat_display.y = selected_display.contentHeight/2
	selected_display:insert( 4, stat_display )
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

        createSelectedDisplay()
        createScrollView()
        createButton()
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