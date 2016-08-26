--[[---------------------------------------
aabb.lua
helpful functions for axis aligned bounding boxes
-----------------------------------------]]

local a = { }

a.doAABBsIntersect = function(aabbOne, aabbTwo)
		local left 	= (aabbOne.xMax >= aabbTwo.xMin and aabbOne.xMin < aabbTwo.xMin)
		local right	= (aabbOne.xMin <= aabbTwo.xMax and aabbOne.xMax > aabbTwo.xMax)
		local up 	= (aabbOne.yMax >= aabbTwo.yMin and aabbOne.yMin < aabbTwo.yMin)
		local down 	= (aabbOne.yMin <= aabbTwo.yMax and aabbOne.yMax > aabbTwo.yMax)

		return (left or right) and (up or down)
end

a.doAABBsOverlap = function( aabbOne, aabbTwo )

	if aabbOne.xMax < aabbTwo.xMin then return false end
	if aabbOne.xMin > aabbTwo.xMax then return false end
	if aabbOne.yMax < aabbTwo.yMin then return false end
	if aabbOne.yMin > aabbTwo.yMax then return false end

	return true
end

--The AABB passed in can be either your own table, or object.contentBounds via Corona's DisplayObject
a.contains_point = function(point, aabb)
		return (point.x < aabb.xMax and point.x > aabb.xMin and point.y > aabb.yMin and point.y < aabb.yMax)
end

a.doesDisplayObjContainPoint = function(point, dispObj)
		return a.doesAABBContainPoint(point, dispObj.contentBounds)
end

a.aabb_inside_aabb = function(aabbA, aabbB)
        return (aabbA.xMin > aabbB.xMin and 
                aabbA.xMax < aabbB.xMax and 
                aabbA.yMin > aabbB.yMin and 
                aabbA.yMax < aabbB.yMax)
end


a.getAABBForNode = function(node)
		return { minX = node.x - node.width * node.anchorX, 
				 maxX = node.x + node.width * (1 - node.anchorX),
				 minY = node.y - node.height * node.anchorY,
				 maxY = node.y + node.height * (1 - node.anchorY) 
				}
end

return a