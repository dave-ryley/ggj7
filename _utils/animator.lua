--[[---------------------------------------
Animator
animator.lua
-----------------------------------------]]

local image_sheets = { }

local a = { }

function a.add_animation( anim_data, group, do_assignment )

	local result = { }

	if group then
		if group.insert then 
			result = group
		else
			print( "Parent supplied to add animation must be a group!" )
			group = nil
		end
	end

	if not image_sheets[ anim_data.image ] then
		image_sheets[ anim_data.image ] = graphics.newImageSheet( anim_data.image, anim_data.animation_data:getSheet( ) )
	end

	local sprite = nil
	
	if group then
		sprite = display.newSprite( group, image_sheets[ anim_data.image ], anim_data.animations )
	else
		sprite = display.newSprite( image_sheets[ anim_data.image ], anim_data.animations )
	end

	if do_assignment then 

		result.sprite = sprite
		
		function result:play_animation( anim )
			result.sprite:setSequence( anim )
			result.sprite:play( )
		end
	end

	return sprite

end

return a