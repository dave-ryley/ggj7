--[[---------------------------------------
vector.lua

Vector math class object
-----------------------------------------]]

local v = { }

--[[---------------------------------------
Useful vectors
-----------------------------------------]]
v.up = { x = 0, y = -1 }
v.down = { x = 0, y = 1 }
v.left = { x = -1, y = 0 }
v.right = { x = 1, y = 0 }


--[[---------------------------------------
tostring( vec ) - returns a string vetor
- IN: vec
- OUT: a string representation of the vector
-----------------------------------------]]
function v.to_string( vec )

	return "( " .. vec.x .. ", " .. vec.y .. " )"
	
end

--[[---------------------------------------
create( x, y ) - constructs and returns a new vector object
- IN: x and y corrdinates for vector
- OUT: vector table
-----------------------------------------]]
function v.create( x, y )

	return { x = x, y = y }

end


--[[---------------------------------------
equals( vecA, vecB ) - returns true if the vectors are equivalent 
- IN: two vectors to compare
- OUT: boolean equality
-----------------------------------------]]
function v.equals( vecA, vecB )

	return vecA.x == vecB.x and vecA.y == vecB.y

end


--[[---------------------------------------
magnitude( vec )
- IN: vector object
- OUT: the magnitude of the vector object
-----------------------------------------]]
function v.magnitude( vec )

	return math.sqrt( vec.x * vec.x + vec.y * vec.y )

end

function v.xy_magnitude( x, y )

	return math.sqrt( x * x + y * y )

end

--[[---------------------------------------
distance( vecA, vecB )
- IN: two points
- OUT: the distance between the points
-----------------------------------------]]
function v.distance( vecA, vecB )

	return v.magnitude( { x = vecA.x - vecB.x, y = vecA.y - vecB.y } )
end

--[[---------------------------------------
sqr_magnitude( vec ) - Cheaper to computer than 
magnitude since it involves no sqrt function. Useful
for comparing vectors.
- IN: vector object
- OUT: the magnitude of the vector object squared
-----------------------------------------]]
function v.sqr_magnitude( vec )

	return vec.x * vec.x + vec.y * vec.y

end

function v.xy_sqr_magnitude( x, y )
	return x * x + y * y
end

--[[---------------------------------------
normalize( vec ) - Normalizes the vector object provided
- IN: vector object
- OUT: nil
-----------------------------------------]]
function v.normalize( vec )

	local mag = v.magnitude( vec )
	vec.x = vec.x / mag
	vec.y = vec.y / mag

end

function v.xy_normalize( x, y )
	local mag = v.xy_magnitude( x, y )
	return x / mag, y / mag
end

--[[---------------------------------------
dot( vecA, vecB ) - Returns the dot product of two vectors
- IN: two vector object
- OUT: dot product
-----------------------------------------]]
function v.dot( vecA, vecB )

	return vecA.x * vecB.x + vecA.y * vecB.y

end

function v.xy_dot( x1, y1, x2, y2 )

	return x1 * x2 + y1 * y2

end

--[[---------------------------------------
add( vecA, vecB ) - Returns the vector addition of two vectors
- IN: two vector objects 
- OUT: resulting vector
-----------------------------------------]]
function v.add( vecA, vecB )

	return { x = vecA.x + vecB.x, y = vecA.y + vecB.y }

end



return v