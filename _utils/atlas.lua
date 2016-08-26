--[[---------------------------------------
Atlas - Manages the loading of images via
texture atlases 

atlas.lua
-----------------------------------------]]

local image_sheets = { }

local atlases = { }

local a = { }

a.register_atlas = function( atlas_path, atlas_data, load_now )

	log( "Registering atlas at " .. atlas_path )

	if atlases[ atlas_path ] then
		-- We already have this atlas loaded, 
		log( "There is already an atlas registered by path " .. tostring( atlas_path ), err )
		return 
	end

	-- Load the atlas data
	atlases[ atlas_path ] = require( atlas_data )

	-- Make sure it loaded correctly
	if atlases[ atlas_path ] == nil then
		log( "There was a problem loading the data for " .. tostring( atlas_path ), err )
		return 
	end

	-- Load the image sheet if load_now is true
	if load_now then
		image_sheets[ atlas_path ] = graphics.newImageSheet( atlas_path, atlases[ atlas_path ]:getSheet( ) )
	end

end

-- This function returns the image associated with frame from atlas_path
a.new_image = function( atlas_path, frame )

	if not atlases[ atlas_path ] then
		log( "Unable to create image " .. frame .. ". The atlas at " .. atlas_path .. " has not yet been registered with the system.", err )
		return 
	end

	-- If the image sheet is not loaded 
	if not image_sheets[ atlas_path ] then
		image_sheets[ atlas_path ] = graphics.newImageSheet( atlas_path, anim_data.animation_data:getSheet( ) )
	end

	-- Create the image and return the object
	return display.newImage( image_sheets[ atlas_path ], atlases[ atlas_path ]:getFrameIndex( frame ) )

end

return a