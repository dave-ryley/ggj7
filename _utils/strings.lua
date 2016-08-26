-----------------------------------------------------------------------------------------
-- strings.lua
-- This is a handy string / text localization file!
-- This file manages all the various translations and allows the game to
-- Update its language in real time.
-----------------------------------------------------------------------------------------

local data = require "_data.string_data"

local strings = { }
en_EN = "en_EN"		-- english
en_GA = "en_GA"		-- irish (gaelic)
en_FR = "en_FR"		-- french
en_IT = "en_IT"		-- italian
en_DE = "en_DE"		-- german
en_ES = "en_ES"		-- spanish
strings.language = en_EN

function strings.get_string( id )

	if data[ id ] and data[ id ][ strings.language ] then 
		return data[ id ][ strings.language ]
	end
	-- If we cant find the string then return the id
	return id
end

return strings



-- -----------------------------------------------------------------------------------------
-- -- Corona display extension function
-- -----------------------------------------------------------------------------------------

-- -- This function will create and return a localized string
-- -- and will track the string internally so it can be updated 
-- function display.newLocalizedText( params )

-- end