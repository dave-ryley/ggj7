--[[---------------------------------------
widgets.lua - emulate corona's widgets

button
-----------------------------------------]]
local W = {}

--[[---------------------------------------
create a graphics button
params:
x, y, 
gfx = graphic filename
text = string
color = text color value (ex. color.orange)
bcolor = background solid button color {r,g,b,a}
click = event function to call when tapped
touch = event function to call when touched
-----------------------------------------]]
function W.button( params )
    local g = display.newGroup()
    local lp = {
        parent = g,
        x = 0,
        y = 0,
        text = "",
        font = params.font,   
        fontSize = params.fontSize,
        align = "center",
    }

    local l = nil
    if not params.font then lp.font = game_font end
    if not params.fontSize then lp.fontSize = 12 end
    if params.text ~= nil then 
        lp.text = params.text
        if params.shadow then
            l = create_shadowed_text( lp )
        else
            l = display.newText( lp )
        end
        
        if params.color ~= nil then
            l:setFillColor(params.color[1], params.color[2], params.color[3], params.color[4])
        end        
    end

    local b
    if params.gfx then
        print( "widgets: create image button "..params.gfx )
        b = display.newImage( g, params.gfx, 0, 0 )
    else
        print( "widgets: create roundedrect button" )
        b = display.newRoundedRect( g, 0, 3, l.width * 1.2, l.height, 10 )
        b:toBack()
    end

    if params.bcolor then
        print( "widgets: set button color" )
        b:setFillColor( params.bcolor[ 1 ], params.bcolor[ 2 ], params.bcolor[ 3 ], params.bcolor[ 4 ] )
        --b:setStrokeColor( 0,0,0 )
        --b.strokeWidth = 7
        b.isHitTestable = true
    end

    if params.click ~= nil then b:addEventListener( "tap", params.click ) end
    if params.touch ~= nil then b:addEventListener( "touch", params.touch ) end
    
    g.x, g.y = params.x, params.y

    g.t = l
    g.b = b

    return g
end


--[[---------------------------------------
create a slider widget 
-----------------------------------------]]
function W.slider( params )

    local g = display.newGroup( )

    local slider = display.newImage( g, params.slider )
    local handle = display.newImage( g, params.handle )

    g.slider = slider
    g.handle = handle

    -- AA Slider Code
    g.coord_0 = params.start
    g.coord_1 = params.final

    g.travel = g.coord_1 - g.coord_0

    g.offset = params.offsets

    g.update_func = params.on_update

    g.end_func = params.on_release

    if params.orientation == "horizontal" then
        g.clamp_to_x = true
        handle.x = g.coord_0
        handle.y = g.offset
    else
        g.clamp_to_y = true
        handle.x = g.offset
        handle.y = g.coord_0
    end

    local function move_handle( grp, x, y )

        local normalized_value = 0

        if grp.clamp_to_x then
            grp.handle.y = grp.handle.offset
            grp.handle.x = grp.handle.x + x

            if grp.handle.x > grp.coord_1 then
                grp.handle.x = grp.coord_1
            elseif grp.handle.x < grp.coord_0 then
                grp.handle.x = grp.coord_0
            end

            normalized_value = ( grp.handle.x - grp.coord_0 ) / grp.travel
        else
            grp.handle.x = grp.handle.offset
            grp.handle.y = grp.handle.y + y

            if grp.handle.y > grp.coord_1 then
                grp.handle.y = grp.coord_1
            elseif grp.handle.y < grp.coord_0 then
                grp.handle.y = grp.coord_0
            end

            normalized_value = ( grp.handle.y - grp.coord_0 ) / grp.travel
        end

        if grp.update_func then
            grp.update_func( normalized_value )
        end
    end

    local function handle_touch( e )

        local handle = e.target
        local parent = e.target.parent

        if e.phase == "began" then
            parent.active_touch = { id = e.id, previous = { x = e.x, y = e.y } }
            return true

        elseif e.phase == "moved" then

            if parent.active_touch and parent.active_touch.id == e.id then
                move_handle( parent, e.x - parent.active_touch.previous.x, e.y - parent.active_touch.previous.y )
                parent.active_touch.previous.x, parent.active_touch.previous.y = e.x, e.y
            end

            return true

        elseif e.phase == "ended" then
            parent.active_touch = nil
            if parent.end_func then
                parent.end_func( )
            end
            return true
        end

    end


    local function bar_touch( e )

        local parent = e.target.parent

        if e.phase == "began" then
        elseif e.phase == "moved" then

            if parent.active_touch and parent.active_touch.id == e.id then
                move_handle( parent, e.x - parent.active_touch.previous.x, e.y - parent.active_touch.previous.y )
                parent.active_touch.previous.x, parent.active_touch.previous.y = e.x, e.y
            end
            return true
            
        elseif e.phase == "ended" then
            parent.active_touch = nil
            if parent.end_func then
                parent.end_func( )
            end
            return true
        end

    end

    -- Get the current normalized value of the slider
    function g.get_value( )
        local normalized_value 

        if g.clamp_to_x then
            normalized_value = ( g.handle.x - g.coord_0 ) / g.travel
        else
            normalized_value = ( g.handle.y - g.coord_0 ) / g.travel
        end

        return normalized_value
    end

    -- Set the value of the slider given a normalized position
    function g.set_value( v )

        -- Sanitize the input
        if v > 1 then v = 1 
        elseif v < 0 then v = 0 end

        if g.clamp_to_x then
            g.handle.x = g.coord_0 + v * g.travel
            g.handle.y = g.handle.offset
        else
            g.handle.y = g.coord_0 + v * g.travel
            g.handle.x = g.handle.offset
        end

        g.update_func( v )

    end




    handle:addEventListener( "touch", handle_touch )
    slider:addEventListener( "touch", bar_touch )

    return g

end

--[[---------------------------------------
create a go button (expanding circles)
params { back, check, [on_update], [state] } 
-----------------------------------------]]
function W.checkbox_button( params )

    local b = display.newGroup( )

    local function onClick( )
        
        b.state = not b.state

        b.check.isVisible = b.state

        if b.on_update then
            b.on_update( b.state )
        end

    end

    if not params.check then
        log( "No check image provided to checkbox button constructor!", err )
        return 
    end

    b.back = W.button( { gfx = params.back, click = onClick } ) 
    b:insert( b.back )
    b.check = display.newImage( b, params.check )


    if not b.check then
        log( "Unable to create check button without a check image.", err )
        return
    end

    b.state = params.state or false

    b.check.isVisible = b.state

    b.on_update = params.on_update

    function b.get_state( )
        return b.state
    end

    function b.set_state( s )
        b.state = s

        b.check.isVisible = b.state

        if b.on_update then
            b.on_update( b.state )
        end
    end

    return b

end

--[[---------------------------------------
create a go button (expanding circles)
-----------------------------------------]]
function W:sa_fade( i )
    local p = self.go_dot[ i ].path
    if not p then return end
    transition.to( self.go_dot[ i ], { time = 300, alpha = 0, onComplete = function() self.go_dot[ i ].alpha = 1 p.radius = 0 self:sa_start( i, 1000 ) end } )
end
function W:sa_start( i, t )
    local p = self.go_dot[ i ].path
    if not p then return end
    transition.to( p, { time = t, radius = 50, onComplete = function() self:sa_fade( i ) end } )
end

function W:go( x, y )
    self.go_group = display.newGroup()
    self.go_dot = {}
    for i = 1,2 do
        self.go_dot[ i ] = display.newCircle( x, y, 25 * ( i - 1 ) )
        self.go_dot[ i ]:setFillColor( 0,0,0,0 )
        self.go_dot[ i ].stroke = { 0.8,0.8,0.8 }
        self.go_dot[ i ].strokeWidth = 6
        self.go_group:insert( self.go_dot[ i ] )
        self:sa_start( i, 1000 - 500 * ( i - 1 ) )
    end
    return self.go_group
end



return W
