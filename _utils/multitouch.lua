-----------------------------------------------------------------------------------------
-- multitouch.lua
-- This file contains functions to enable and process multitouch
-----------------------------------------------------------------------------------------

local is_device = ( system.getInfo( "environment" ) == "device" )

local separation_sensitivity = 20
local pan_sensitivity = 10
local pan_spread_sensitivity = 0.8

local function circle_update( circle, event )

	circle.x, circle.y = event.x, event.y

end

local function create_circle_listener( mtouch, event )

	local circ = display.newCircle( mtouch.group, event.x, event.y, 30 )
	circ.alpha = 0.5

	function circ:touch( e )

		local target = circ

		if e.phase == "began" then

			display.getCurrentStage( ):setFocus( target, e.id )  -- set touch focus on this object
         	target.hasFocus = true  -- remember that this object has the focus

		elseif e.phase == "moved" then

			if mtouch.debug_touch_move then
				for k,v in pairs( mtouch.saved_touches ) do
					v.x = v.x + ( e.x - target.x )
					v.y = v.y + ( e.y - target.y )
				end
			end

			target.x, target.y = e.x, e.y
			mtouch:process_touch( )

		else -- Phase is ended or canceled

		 	display.getCurrentStage( ):setFocus( target, nil )  -- remove touch focus
            target.hasFocus = false  -- this object no longer has the focus

            mtouch:remove_touch( e.id )
			mtouch:process_touch( )

		end

		if mtouch.touch_count > 1 then
			return true
		end
	end

	circ.update = circle_update

	-- circ:addEventListener( "touch" )
	-- circ:touch( event )

	return circ

end

local function debug_key_listener( mtouch, e )

	if e.keyName == "space" then
		if e.phase == "down" then
			mtouch.debug_touches = true
		else
			mtouch.debug_touches = false
			-- Remove all current saved touches
			for k,_ in pairs( mtouch.saved_touches ) do
				mtouch:remove_touch( k )
			end
			mtouch.saved_touches = { }
			mtouch:process_touch( )
		end

		mtouch.debug_touch_move = e.isCtrlDown
	end

end

local function mtouch_process_touch( self )


	-- If there are two touches then process the two touch events
	if self.touch_count == 2 then

		-- Setup the relevant data for this touch
		local time = system.getTimer( )
		local positions = { }
		local touch_ids = { }
		for k,v in pairs( self.active_touches ) do
			touch_ids[ #touch_ids + 1 ] = k
			positions[ k ] = { v.x, v.y } 
		end

		local dx, dy = positions[ touch_ids[ 1 ] ][ 1 ] - positions[ touch_ids[ 2 ] ][ 1 ], positions[ touch_ids[ 1 ] ][ 2 ] - positions[ touch_ids[ 2 ] ][ 2 ]
		local separation = vector.xy_magnitude( dx, dy )

		-- If this is the first detection then set up the listeners
		if not self.two_touch_data then
			self.two_touch_data = { }
			
			self.two_touch_data.time = time
			self.two_touch_data.initial_positions = positions
			self.two_touch_data.initial_separation = separation

			send_message( "two-finger-touch", { phase = "began" } )
			return
		end

		-- If we have not dermined the gesture yet then test to see if one has been determined
		if not self.two_touch_data.state then 

			-- Test for pinch
			local d_separation = separation - self.two_touch_data.initial_separation

			if math.abs( d_separation ) > separation_sensitivity then
				self.two_touch_data.pinch_start = separation
				self.two_touch_data.state = "pinch"
			else
				-- Test for pan
				-- Get the delta vectors for the two points
				local d1x = positions[ touch_ids[ 1 ] ][ 1 ] - self.two_touch_data.initial_positions[ touch_ids[ 1 ] ][ 1 ]
				local d1y = positions[ touch_ids[ 1 ] ][ 2 ] - self.two_touch_data.initial_positions[ touch_ids[ 1 ] ][ 2 ]

				local d2x = positions[ touch_ids[ 2 ] ][ 1 ] - self.two_touch_data.initial_positions[ touch_ids[ 2 ] ][ 1 ]
				local d2y = positions[ touch_ids[ 2 ] ][ 2 ] - self.two_touch_data.initial_positions[ touch_ids[ 2 ] ][ 2 ]

				local d1_mag = vector.xy_magnitude( d1x, d1y )
				local d2_mag = vector.xy_magnitude( d2x, d2y )

				-- If the touches have traveled far enough
				if d1_mag > pan_sensitivity and d2_mag > pan_sensitivity then 
					-- Check the dot product to see if the movement is in the same directions
					-- Normalize the inputs so they are easier to deal with
					local dot = vector.xy_dot( d1x / d1_mag, d1y / d1_mag, d2x / d2_mag, d2y / d2_mag )

					if dot > pan_spread_sensitivity then
						local sx = ( positions[ touch_ids[ 1 ] ][ 1 ] + positions[ touch_ids[ 2 ] ][ 1 ] ) / 2 
						local sy = ( positions[ touch_ids[ 1 ] ][ 2 ] + positions[ touch_ids[ 2 ] ][ 2 ] ) / 2 

						self.two_touch_data.pan_start = { sx, sy }
						self.two_touch_data.state = "pan"
					end

				end

			end

		end

		if self.two_touch_data.state then

			if self.two_touch_data.state == "pinch" then
				send_message( "two-finger-touch", { phase = "moved", state = "pinch", start = self.two_touch_data.pinch_start, separation = separation } )
			elseif self.two_touch_data.state == "pan" then	
				local cx = ( positions[ touch_ids[ 1 ] ][ 1 ] + positions[ touch_ids[ 2 ] ][ 1 ] ) / 2 
				local cy = ( positions[ touch_ids[ 1 ] ][ 2 ] + positions[ touch_ids[ 2 ] ][ 2 ] ) / 2 

				send_message( "two-finger-touch", { phase = "moved", state = "pan", start = self.two_touch_data.pan_start, current = { cx, cy } } )
			end

		end

	else -- If the count is not equal to two remove any data we have lying around
		if self.two_touch_data then 
			self.two_touch_data = nil
			send_message( "two-finger-touch", { phase = "ended" } )
		end
	end

end

local function mtouch_remove_touch( self, id )

	if self.active_touches[ id ] then

		if self.debug_touches then 
			self.saved_touches[ id ] = self.active_touches[ id ]
		else
			local circ = self.active_touches[ id ]
			circ:removeSelf( )

			self.active_touches[ id ] = nil
			self.touch_count = table_size( self.active_touches )
		end

	else
		log( "No touch currently active with id " .. tostring( id ) )
	end

end


local function mtouch_initialize_listener( self )

	-- Initialize multitouch!
	if is_device then 
		system.activate( "multitouch" ) 
	else
		self.key_listener = function( e )
			debug_key_listener( self, e )
		end
		Runtime:addEventListener( "key", self.key_listener )
	end

	local touch_group = display.newGroup( )

	self.active_touches = { }
	self.saved_touches = { }
	self.touch_count = 0

	-- Set up the touch intercept rect
	local rect = display.newRect( touch_group, _XC, _YC, _W * 2, _H * 2 )
	rect.alpha = 0
	rect.isHitTestable = true

	self.main_listener = function( e )

		local target = e.target

		if e.phase == "began" then

			local circ = create_circle_listener( self, e )
			self.active_touches[ e.id ] = circ
			self.touch_count = table_size( self.active_touches )

			self:process_touch( )

		elseif e.phase == "moved" then

			local circ = self.active_touches[ e.id ]
			if circ then

				if self.debug_touch_move then
					for k,v in pairs( self.saved_touches ) do
						v.x = v.x + ( e.x - circ.x )
						v.y = v.y + ( e.y - circ.y )
					end
				end

				circ:update( e )

				self:process_touch( )

			end

		else -- Ended or Cancelled

			self:remove_touch( e.id )
			self:process_touch( )

		end

		if self.touch_count > 1 or table_size( self.saved_touches ) > 0 then
			return true
		end

	end


	rect:addEventListener( "touch", self.main_listener )

	self.group = touch_group
	self.rect = rect

end

local function mtouch_shutdown_listener( self )

	if is_device then 
		system.deactivate( "multitouch" ) 
	else
		Runtime:removeEventListener( "key", self.key_listener )
		self.key_listener = nil
	end

	self.active_touches = nil
	self.saved_touches = nil
	self.touch_count = nil

	self.rect:removeSelf( )
	self.group:removeSelf( )

	self.rect = nil
	self.group = nil

end

local m = { }

function m.new_listener( )

	local listener = { }

	listener.initialize_listener = mtouch_initialize_listener
	listener.shutdown_listener = mtouch_shutdown_listener

	listener.process_touch = mtouch_process_touch
	listener.remove_touch = mtouch_remove_touch

	return listener

end




return m
