-- the input module
local input = {}

-- records whether or not a key is down
input.keyStates = {}
-- records the current value of an axis
input.axisStates = {}

local function onKeyEvent (event)
	--[[
	print(event.keyName .. " pressed")
	--]]

	if event.phase == "down" then
		input.keyStates[event.keyName] = true

	elseif event.phase == "up" then
		input.keyStates[event.keyName] = false
	end
end

Runtime:addEventListener("key", onKeyEvent)

local function onAxisEvent (event)
	--[[
	print("axis no. " .. event.axis.number .. " has a value of " .. event.normalizedValue)
	--]]

	input.axisStates[event.axis.number] = event.normalizedValue
end

function input:getAxis(axis)
	if input.axisStates[axis] then
		return input.axisStates[axis]
	else
		return 0
	end
end

Runtime:addEventListener("axis", onAxisEvent)

return input