 --[[---------------------------------------
utils.lua

important variables
-----------------------------------------]]
_W                  = display.contentWidth 
_H                  = display.contentHeight
_XC                 = _W / 2
_YC                 = _H / 2

debug_curves --[[-------]]  = false
debug_print  --[[-------]]  = true

print( "Application width: " .. _W )
print( "Application height: " .. _H )

json = require "json"

local composer = require "composer"

--hard-coded constants that provide radian/degrees translating
deg_to_rad = .0174532925
rad_to_deg = 57.2957795

--[[---------------------------------------
important functions
-----------------------------------------]]

--[[------------------------------------------
Rounding of num to idp decimal places

round(1023.4345) = 1023
round(1023.4345, 2) = 1023.43
round(1023.4345, -2) = 1000
--------------------------------------------]]
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

--[[---------------------------------------
returns the size of the given table
-----------------------------------------]]
function table_size( tbl )
    local count = 0
    for _,v in pairs( tbl ) do
        count = count + 1
    end
    return count 
end

--[[---------------------------------------
Helper function for loading and saving data
-----------------------------------------]]
function load_table( path )

    local p = system.pathForFile( path, system.DocumentsDirectory )
    local f,msg = io.open( p, "r" )
    if f then
        local encoded = f:read( "*all" )
        f:close( )
        return json.decode( encoded )
    else
        log( msg, err )
    end
end

function save_table( data, path )

    local path = system.pathForFile( path, system.DocumentsDirectory )
    local f, msg = io.open( path, "w+" )
    if f then
        local encoded = json.encode( data )
        f:write( encoded )
        f:close()

        return true
    else
        log( msg, err )

        return false
    end

end

--[[------------------------------------------
Returns the sign of a number -1, 1, or 0
--------------------------------------------]]
function math.sign( num )

    if num > 0 then return 1 end
    if num < 0 then return -1 end
    return 0

end

--[[------------------------------------------
compare lists, returns true if they contain the same
elements in the same order, regardless of the starting position
--------------------------------------------]]
function array_equivalent( a, b )

    if #a ~= #b then return false end

    if #a == 0 then return true end

    local len = #a
    -- Find the start
    local start
    for i = 1, len do
        if b[ i ] == a[ 1 ] then 
            start = i
            break
        end
    end

    -- If no start was found return false
    if not start then return false end

    for i = 1, len do

        local curr = start + ( i - 1 )
        if curr > len then curr = curr - len end

        if a[ i ] ~= b[ curr ] then return false end

    end

    -- If we made it here then the lists match!
    return true 

end

--[[-----------------------------------
create a text object with a shadow text behind it
params argument is a normal text object construction argument table 
---------------------------------------]]
function create_shadowed_text( params )

    local result = display.newGroup( )

    if params then
        if params.x then result.x = params.x; params.x = 0 end
        if params.y then result.y = params.y; params.y = 0 end
        if params.parent then params.parent:insert( result ); params.parent = result
        else params.parent = result end
    end

    result.text = display.newText( params )
    result.shadow = display.newText( params )

    result.shadow:toBack( )
    result.shadow.x = -2
    result.shadow.y = 2
    result.shadow:setFillColor( 0.1, 0.1, 0.1 )

    function result:setColor( r, g, b )
        result.text:setFillColor( r, g, b )
    end

    function result:setShadowColor( r, g, b )
        result.shadow:setFillColor( r, g, b )
    end

    function result:setText( string )
        result.text.text = string
        result.shadow.text = string
    end

    function result:getText()
        return result.text.text
    end

    return result

end

--[[-----------------------------------
create a rect that has a shadow
---------------------------------------]]
function create_shadowed_rect( params )

    local group = display.newGroup( )

    local shadow = display.newRoundedRect( group, -10, 10, params.width, params.height, params.cornerRadius )
    shadow:setFillColor( 0.1, 0.1, 0.1 )

    local rect = display.newRoundedRect( group, 0, 0, params.width, params.height, params.cornerRadius )
    shadow:setFillColor( 0.1, 0.1, 0.1 )

    if params.parent then 
        params.parent:insert( group )
    end

    group.rect = rect
    group.shadow = shadow

    group.x = params.x
    group.y = params.y

    return group

end


--[[---------------------------------------
random function
    if there are two args, then a random integer in range [ from, to ] is returned 
    if there is one arg, then a random integer in range [ 1, to ] is returned
    if there are no args, then a random real number in range [ 0, 1 ] is returned
-----------------------------------------]]
function rnd( from, to )
    -- Two arguments, return [ from, to ]
    if from and to then
        return math.random( from, to )
    -- One argument return [ 1, to ]
    elseif from and not to then
        return math.random( from )
    -- No arguments return [ 0, 1 ]
    else
        return math.random( )
    end
end

--[[------------------------------------------
Functions for skaking a display object, example would be passing in a scene view for a camera shake event
--------------------------------------------]]
function do_shake_object( obj, count )
    if not count then count = 1 end

    if count > 0 then
        shake_object( obj, function( ) do_shake_object( obj, count-1 ) end )
    end
end

function shake_object( obj, onComplete )

    transition.to( obj, { time = 20, x = 10, delta = true, onComplete = function( )
        transition.to( obj, { time = 40, x = -20, delta = true, onComplete = function( )
            transition.to( obj, {time = 20, x = 0, onComplete = onComplete } )
        end } )
    end } )
end

function shake_display( count )

    do_shake_object( display.getCurrentStage( ), count )

end

--[[------------------------------------------
denote where we are debugging
--------------------------------------------]]
function debug_highlight( what )
    print( "====================================================================")
    print( "            DEBUGGING "..what )
    print( "                DEBUGGING "..what )
    print( "                    DEBUGGING "..what )
    print( "====================================================================")
end

--[[---------------------------------------
messaging functions

add_message: sets up a function that can be called when a message is sent
send_message: this will send the message out to the codebase
remove_message: removes a message so it cannot be caught anymore

typical use:

add_message( "your-message", function_name )    -- ex. you want your HUD to update from anywhere
send_message( "your-message", params )          -- sends the message and function_name is called with parameters
remove_message( "your-message" ) -- removes the message & function_name from the messaging system

-----------------------------------------]]
local messages = {}

function send_message( msg, params )
    -- log( "Sending: " .. msg )
    local e = { name = msg }
    if params then
        for k,v in pairs( params ) do
            e[k] = v
        end
    end
    Runtime:dispatchEvent( e )
end

function add_message( msg, func )
    messages[ msg ] = func
    Runtime:addEventListener( msg, func )
    --print( "add_message: "..msg..", function = "..inspect( func ) )
end

function remove_message( msg )
    local func = messages[ msg ]
    messages[ msg ] = nil
    Runtime:removeEventListener( msg, func )
    --print( "remove_message: "..msg..", function = "..inspect( func ) )
end

--[[------------------------------------------
Helper function for finding the angle between two points
--------------------------------------------]]
function angleBetween( srcX, srcY, dstX, dstY )
    local angle = ( math.deg( math.atan2( dstY-srcY, dstX-srcX ) )+90 )
    return angle % 360
end

--[[------------------------------------------
get a distance for 2 points
get_distance( {x1,y1}, {x2,y2} )
--------------------------------------------]]
function get_distance(vecA, vecB)
        local xDist = vecA.x - vecB.x
        local yDist = vecA.y - vecB.y
        return math.sqrt(xDist * xDist + yDist * yDist)
end

--[[------------------------------------------
call this to generate the curve
IN: segNum = how many path segments you want
    anchorPoints = { start, start_guide, end_guide, end } each is { x = val, y = val }
--------------------------------------------]]
function generate_curve( segNum, anchorPoints )

    local inc = ( 1.0 / segNum )

    local pathPoints = { }

    for j = 1,segNum do
        pathPoints[#pathPoints+1] = { x=0, y=0 }
    end 

    -- Code added to add the end to the point list
    pathPoints[#pathPoints+1] = anchorPoints[4]

    for i = 1,#anchorPoints,4 do

        local t = 0
        local t1 = 0
        local i = 1

        for j = 1,segNum do 

            t1 = 1.0 - t
            local t1_3 = t1 * t1 * t1
            local t1_3a = (3*t) * (t1*t1)
            local t1_3b = (3*(t*t)) * t1
            local t1_3c = t * t * t
            local p1 = anchorPoints[i]
            local p2 = anchorPoints[i+1]
            local p3 = anchorPoints[i+2]
            local p4 = anchorPoints[i+3]
    
            local x = t1_3 * p1.x
            x = x + t1_3a * p2.x
            x = x + t1_3b * p3.x
            x = x + t1_3c * p4.x

            local y = t1_3 * p1.y
            y = y + t1_3a * p2.y
            y = y + t1_3b * p3.y
            y = y + t1_3c * p4.y

            pathPoints[j].x = x
            pathPoints[j].y = y
            t = t + inc
        end
    end
    
    return pathPoints

end


function draw_curve( points, group )

    local result = nil

    if #points > 2 then

    	if group then
    		result = display.newLine( group, points[ 1 ].x, points[ 1 ].y, points[ 2 ].x, points[ 2 ].y )
    	else
	        result = display.newLine( points[ 1 ].x, points[ 1 ].y, points[ 2 ].x, points[ 2 ].y )
	    end

        for i = 3, #points do

            result:append( points[ i ].x, points[ i ].y )

        end



    end

    return result

end


--[[------------------------------------------
This function transitions a display objects along a path of points
IN: obj = the display object to apply the transition to
    pathPoints = an array of points {x = val, y = val } to follow
    params = an options table for customizing behavior
                - num  time                 : the total time for the transition to take
                - num  speed                : the speed at which the object will travel along the path, in pixels per milisecond. Choose either time or speed, not both
                - bool rotate               : if true, the object will rotate so that facing the direction of travel
                - bool smoothRotation       : if true, the object will smoothly rotate 
                - table parent              : a table that gets assigned a reference to the current transition in the field follow_trans
                - func transition           : an easing function from the easing library, just as in the transition functions
                - func onComplete           : a function to call when path ends
--------------------------------------------]]
function transition_curve( obj, points, params, id )
    print ("id "..id)
    local nextPoint = 2

    local onComplete = nil
    local duration = nil
    local speed = nil
    local rotate = false
    local smoothRotation = false
    local parent = nil
    local easer = nil
    local total_distance = 0
    local elapsed_distance = 0
    local elapsed_time = 0

    for i = 2, #points do

        local dist = get_distance( points[ i - 1], points[ i ] )
        points[ i ].dist = dist

        total_distance = total_distance + dist

    end

    if params then

        if params.onComplete then onComplete = params.onComplete end
        if params.time then duration = params.time end
        if params.speed then speed = params.speed end
        if params.rotate then rotate = params.rotate end
        if params.smoothRotation then smoothRotation = params.smoothRotation end
        if params.parent then parent = params.parent end

        if params.transition then easer = params.transition else easer = easing.linear end 

        if duration and speed then 
            segmentDuration = nil
            print( "Cannot specify both time and speed, please choose one or the other. Defaulting to time." )
        end

        if not (duration or speed) then
            print( "Must specify either a time or a speed!" )
            return 
        end

    end

    local dbg_curve = nil 
    if debug_curves then dbg_curve = draw_curve( points, obj.parent ) end

    local function nextTransition( )

        if nextPoint > #points then
            if dbg_curve then dbg_curve:removeSelf( ) end
            if onComplete then onComplete( ) end
            if parent then parent.follow_trans = nil end
        else
            local segmentDuration = 0



            if duration then

                if easing then

                    segmentDuration = easer( elapsed_distance + points[ nextPoint ].dist, total_distance, 0, duration ) - elapsed_time
                    elapsed_distance = elapsed_distance + points[ nextPoint ].dist
                    elapsed_time = elapsed_time + segmentDuration

                --else
                 --   segmentDuration = duration * points[ nextPoint ].dist / total_distance 
                end

                
            elseif speed then
               segmentDuration = points[ nextPoint ].dist / speed
            end

            if ( rotate or smoothRotation ) and nextPoint < #points then

                if smoothRotation then

                    transition.to( obj, { rotation = angleBetween( obj.x, obj.y, points[nextPoint].x, points[nextPoint].y ), time = segmentDuration, tag = id } )
                else
                    obj.rotation = angleBetween( obj.x, obj.y, points[nextPoint].x, points[nextPoint].y )
                end

            end

           

            local follow_trans = transition.to( obj, {
                tag = id,
                time = segmentDuration,
                x = points[nextPoint].x,
                y = points[nextPoint].y,
                onComplete = nextTransition
            } )

            nextPoint = nextPoint + 1

            if parent then parent.follow_trans = follow_trans end

        end

    end

    

    nextTransition( )

end

--[[------------------------------------------
print out an entire table's data 
--------------------------------------------]]
function print_r( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

--[[------------------------------------------
C like __FILE__ and __LINE__ functions
--------------------------------------------]]

-- __FILE__
function dbg_file( sl )
    if sl == nil then sl = 2 end
    return debug.getinfo(sl,'S').source
end

-- __LINE__
function dbg_line( sl )
    if sl == nil then sl = 2 end
    return debug.getinfo(sl, 'l').currentline
end

-- Returns just the file name without full path
function dbg_short_file( sl )
    if sl == nil then sl = 3 end
    return string.match( dbg_file( sl ), ".*[\\\/](.*)" )
end


--[[------------------------------------------
Logging utility functions
--------------------------------------------]]

-- Logging constants
err = "ERROR"
warn = "WARNING"

function log( msg, lvl )
    if lvl == nil then lvl = "LOG" end

    local rslt = "nil"
    if system.getInfo( "environment" ) == "simulator" then
        rslt = lvl .. ": " .. dbg_short_file( 4 ) .. ":" .. dbg_line( 3 ) .. ", " .. msg
    else
        rslt = lvl .. ": " .. msg
    end
    
    print( rslt )
end


--[[------------------------------------------
change scenes a better way
IN: scene = name of lua file
    t = time in milliseconds
    options = {} with composer options in it
--------------------------------------------]]
function change_scene( scene, t, options )
    local black = display.newRect( 0, 0, _W, _H )
    black:setFillColor( 0,0,0 )

    black.anchorX, black.anchorY = 0,0
    black.alpha = 0
    -- fade to black
    transition.to( black, { alpha = 1.0, time = t / 2, 
        onComplete = 
            function()
                -- change scenes instantly
                local o = {}
                if options then o = options end
                o.time = 1
                print( "globals: change_scene = "..scene )
                -- print_r( o )
                composer.gotoScene( scene, o )
                -- and fade back in & delete the black
                transition.to( black, { alpha = 0, time = t / 2, onComplete = function() display.remove( black ) end } )
            end } )

    if options and options.block_input then 
        black:addEventListener( "tap", 
            function( )
                return true
            end )
        black:addEventListener( "touch", 
            function( )
                return true
            end )
    end
end
