-----------------------------------------------------------------------------------------
-- graph_processing.lua
-- This file contains general graph functions
-----------------------------------------------------------------------------------------

local g = { }
local white = "w"
local gray = "g"
local black = "b"

local math_atan2 = math.atan2

-- graph to process
-- source edge in question
-- direction of travel along source
-- target edge that we are looking for
-- found edges along the way
local function traverse_edges( graph, source, direction, target, target_dir, found )

	-- Mark the source as traversed
	source.traversed = source.traversed + direction

	-- Get the target vert
	local vert_id = source[ direction ]
	local vert = graph.verts[ vert_id ]

	-- log( "At vert " .. vert_id )

	-- Check for connections
	-- if #vert[ 3 ] < 2 then return false end

	-- Find the source connection index
	local source_idx
	for i = 1, #vert[ 3 ] do
		if graph.edges[ vert[ 3 ][ i ] ] == source then
			source_idx = i
			break
		end
	end

	-- log( "Came from edge " .. vert[ 3 ][ source_idx ] )

	-- Make sure we have a source
	if source_idx == nil then 
		log( "Something went horribly wrong. Unable to find source edge while traversing.", err )
		return 
	end

	-- Get the most Clockwise edge
	local next_idx = source_idx - 1
	if next_idx == 0 then
		next_idx = #vert[ 3 ]
	end

	-- log( "Next edge is " .. vert[ 3 ][ next_idx ] )

	-- Get the next edge of the traversal
	local next_edge = graph.edges[ vert[ 3 ][ next_idx ] ]

	-- Add this edge to the found list 
	found[ #found + 1 ] = { vert[ 3 ][ source_idx ], direction }

	

	-- Find the direction of travel along the next edge
	local next_dir = 1
	if next_edge[ 1 ] == vert_id then
		next_dir = 2 
	end

	-- Check to see if the next edge is our target
	if next_edge == target and next_dir == target_dir then
		-- Return the list of found edges
		-- log( "Found a cycle!" )
		return found
	end

	-- log( "The next direction is: " .. next_dir )
	-- log( "The next traversed is: " .. next_edge.traversed )

	if next_edge.traversed == 3 or next_edge.traversed == next_dir then 
		log( "The graph has already traversed this edge in this direction! Something strange may be about to happen...", warn )
	end

	

	-- Dive into the next edge
	return traverse_edges( graph, next_edge, next_dir, target, target_dir, found )
end

-- Find the minimum clockwise cycles in a graph
function g.find_minimum_cycles( g )

	-- Reset the traversed flags
	for _,edge in ipairs( g.edges ) do
		edge.traversed = 0
	end

	local results = { }

	-- Calculate the target number of cycles
	local target_cycle_count = #g.edges - #g.verts + #g.components

	for _, component in ipairs( g.components ) do
		-- Make sure every edge in this component has been traversed
		for i, edge_id in ipairs( component.edges ) do
			-- Get the edge
			local edge = g.edges[ edge_id ]
			-- If the edge has not been fully traversed
			if edge.traversed < 3 then -- Begin a graph traversal from this edge

				-- Find the direction in which to travel : bit flags 1 for towards 1 and 2 for towards 2
				local direction = 1
				if edge.traversed == 1 then
					direction = 2
				end

				-- log( "Starting pass from edge " .. edge_id .. " in direction " .. direction )

				local result = traverse_edges( g, edge, direction, edge, direction, { } )

				if result then 
					results[ #results + 1 ] = result
				end

			end
		end
	end

	-- Process the results, remove the extra cycle 
	local point_results = { }

	for _,r in ipairs( results ) do
		local point_result = { }
		local point_total = 0
		for _,edge_dir in ipairs( r ) do
			local edge = g.edges[ edge_dir[ 1 ] ]
			local vert_idx = edge[ edge_dir[ 2 ] ]
			local vert_dir = g.verts[ vert_idx ]
			local vert_other = g.verts[ edge[ 3 - edge_dir[ 2 ] ] ]

			point_total = point_total + ( vert_other[ 1 ] - vert_dir[ 1 ] ) * ( vert_other[ 2 ] + vert_dir[ 2 ] )

			point_result[ #point_result + 1 ] = vert_idx
		end

		-- log( point_total )
		if point_total > 0 then 
			point_results[ #point_results + 1 ] = point_result
		end

	end

	-- log( #point_results .. " cycles present" )
	-- print_r( g.verts )
	-- print_r( g.edges )
	-- print_r( g.components )
	return point_results

end

-- Given points and lines, create a graph object 
-- NOTE: This function ASSUMES the data given to it is planar, if it is not then weird thigns may happen
function g.create_graph( v, l )

	-- Clone the list of verts
	local verts = { }
	for i = 1, #v do
		verts[ i ] = { v[ i ][ 1 ], v[ i ][ 2 ], color = white }
	end

	-- Clone the list of lines
	local lines = { }
	for i = 1, #l do
		lines[ i ] = { l[ i ][ 1 ], l[ i ][ 2 ] }
	end

	-- Establish the vertex connections
	for i = 1, #verts do 
		local curr = verts[ i ]

		-- log( "Processing connections for " .. i )

		-- Create the table of connections
		local connections = { }

		-- Go through each line to find all connections to this vert
		for j = 1, #lines do
			local line = lines[ j ]
			-- If the line contains the current vert
			-- Then add it to the connections table
			if line[ 1 ] == i or line[ 2 ] == i then
				connections[ #connections + 1 ] = j
			else
			end
		end

		-- If there are connections to this vert
		if #connections > 0 then
			local ordered = { }
			local angles = { }
			-- Sort the connections in clockwise order
			for j = 1, #connections do
				local line_i = connections[ j ] 

				local tgt_i = lines[ line_i ][ 1 ]
				if tgt_i == i then 
					tgt_i = lines[ line_i ][ 2 ]
				end

				local tgt = verts[ tgt_i ]
				-- Get the angle 
				local dx, dy = tgt[ 1 ] - curr[ 1 ], tgt[ 2 ] - curr[ 2 ]
				local angle = math_atan2( dy, dx ) * rad_to_deg
				if angle < 0 then angle = 360 + angle end

				angles[ j ] = angle
			end

			-- Create the order for the connections
			for j = 1, #connections do
				if #ordered > 0 then
					local insert_idx = 0
					for k = 1, #ordered do
						if angles[ j ] < angles[ ordered[ k ] ] then
							insert_idx = k
							break
						end
					end
					if insert_idx == 0 then insert_idx = #ordered + 1 end

					table.insert( ordered, insert_idx, j )
				else
					ordered[ 1 ] = j
				end
			end

			-- Order the connections
			curr[ 3 ] = { }
			for j = 1, #ordered do
				curr[ 3 ][ j ] = connections[ ordered[ j ] ]
			end
		else
			-- Remove this vert from the graph, we dont care about it
			curr[ 3 ] = { }
		end

	end

	-- Create the table of connected components
	local forest = { }

	-- The table of verts to proceess
	local to_process = { }

	-- While there are still white nodes in the verts array
	for vert_i, vert in ipairs( verts ) do

		-- Create a connected component
		local curr_connected_component = { }
		curr_connected_component.edges = { }

		if vert.color == white then
			to_process[ #to_process + 1 ] = vert_i

			while #to_process > 0 do 

				-- Pop the first element off the list
				local curr_i = to_process[ 1 ]
				local curr = verts[ curr_i ]
				table.remove( to_process, 1 )

				-- If the first element is white
				if curr.color ~= black then
					
					-- Mark it as black and add its neighbors to the list
					curr.color = black

					for i = 1, #curr[ 3 ] do
						local test_i
						local line = lines[ curr[ 3 ][ i ] ]
						if line[ 1 ] == curr_i then
							test_i = line[ 2 ]
						else
							test_i = line[ 1 ]
						end
						-- If the neighbor is white then add it to the list
						if verts[ test_i ].color == white then
							verts[ test_i ].color = gray
							to_process[ #to_process + 1 ] = test_i 
						end

						local found = false
						for j = 1, #curr_connected_component.edges do
							if curr_connected_component.edges[ j ] == curr[ 3 ][ i ] then
								found = true
								break
							end
						end

						if not found then 
							curr_connected_component.edges[ #curr_connected_component.edges + 1 ] = curr[ 3 ][ i ]
						end

					end

					-- Add curr to the current connected component
					curr_connected_component[ #curr_connected_component + 1 ] = curr_i

				end

			end -- whle #to_process > 0 do

			-- We are done with this connected component, add it to the forest and find the next white vertext if it exists
			forest[ #forest + 1 ] = curr_connected_component


		end
		
	end -- vert_i, vert in ipairs( verts ) do

	local graph = { }

	graph.verts = verts
	graph.edges = lines
	graph.components = forest

	return graph

end


return g