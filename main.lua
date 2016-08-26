require "globals"
require (utils_directory .. ".utils")
require (utils_directory .. ".input")
local composer = require "composer"

native.setProperty("windowMode", "fullscreen")

composer.gotoScene( scenes_directory .. ".action")