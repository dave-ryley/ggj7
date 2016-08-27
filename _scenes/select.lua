local composer = require "composer"
local widget = require "widget"
local scene = composer.newScene()
local scale = 2

--local padding = math.round((svw - tiles.width * scale) / 2)
local players_display = display.newGroup( )
--local button_size = 170 * scale + padding * 2
local button_size = 170
local svw = button_size
local selection_rect = display.newRect( -500, -500, button_size, button_size )
local selected_string = ""
local selection = 0
local moved = false
local numPlayers = 2
local selected_display = display.newGroup( )
selected_display.x = 170
selected_display.contentWidth = dcw - button_size
selected_display.contentHeight = dch
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


local tiles_list = {}
--print("padding: " .. padding)
--[[
for i=1, #tiles.get do
	if tiles.get[i].name then
		tiles_list[#tiles_list + 1] = tiles.get[i]
	end
end
]]
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
				if selected_display.numChildren > 0 then
					selected_display[1]:removeSelf( )
				end
				players_display[players_display.numChildren]:removeSelf( );
				local top_line = display.newLine( 	2, (selection - 1) * button_size,
													button_size - 3, (selection - 1) * button_size,
													button_size - 3, selection * button_size,
													2, selection * button_size,
													2, (selection - 1) * button_size)

				--selection_rect.alpha = 0
				top_line.strokeWidth = 3
				--selection_rect:setFillColor( 0.5 )
				top_line:setStrokeColor( 1, 0, 0 )
				players_display:insert(top_line)
				selected_string = players_gfx_directory.."player"..selection..".png"
				local s = display.newImage( 		selected_display, 
													selected_string, 
													selected_display.contentWidth/2, 
													selected_display.contentHeight/2 )
				s:scale(2, 2)
			end
			
		end
		
		moved = false
	end
	return true
end


local scrollView = widget.newScrollView(
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
print(dch)
--local background = display.newRect( scrollView.x, scrollView.y, scrollView.width, scrollView.height* 5 )
--background:setFillColor( 0.5)

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