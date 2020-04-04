extends AStar

const GODOT_FIX = 1 #Astar doesn't seem to like decimal weights

# Declare member variables here. Examples:
var radius = 10
var cube_directions = [
   Vector3(1, -1, 0), Vector3(1, 0, -1), Vector3(0, 1, -1), 
	Vector3(-1, 1, 0), Vector3(-1, 0, 1), Vector3(0, -1, 1)
]

var offset = Vector3(0,0,0)

enum NEIGHBORS {RIGHT = 0, TOP_RIGHT = 1, TOP_LEFT = 2, LEFT = 3, BOTTOM_LEFT = 4, BOTTOM_RIGHT = 5}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#Note: This code is adapted largely from https://www.redblobgames.com/grids/hexagons/#distances
#If you would like to learn more, I recommend that you read that blog post.
#It turns out that offset coordinates (the ones used by default in Godot)
#are severely lacking in functionality and make many operations much harder.
#As such, all operations here are done in terms of cube coordinates
#I leave this final note for posterity: no sane human should ever have to work
#in hexagonal coordinates.  It's an affront to the dignity of man.


func get_radius():
	return radius

func set_position_offset(pos: Vector3, costs: FuncRef):
	offset = pos
	update_costs(costs)
	
#Return tile indices inside radius
#Returns cube indices
#pos is tile cube coordinates
func get_tiles_inside_radius(pos: Vector3, _radius = 1):
	var tiles = []
	
	for a in range(-_radius, _radius + 1):
		for b in range(int(max(-_radius, -a-_radius)), int(min(_radius, _radius-a) + 1)):
			tiles.append(Vector3(a, b, -a-b) + pos)
	
	return tiles

func map_Z_to_N(x):
	if x >= 0:
		return 2*x
	else:
		return -2*x-1
		
#injective hash function for integers
func map_ZxZ_to_N(x, y):
	var n_x = map_Z_to_N(x)
	var n_y = map_Z_to_N(y)
	
	return int((n_x + n_y)*(n_x + n_y + 1) / 2 + n_y)

#All functions dealing with the map must now accept cube coordinates
func initialize_astar(_radius: int, costs: FuncRef):
	radius = _radius
	var positions = []
	var temp_vec = Vector3(0,0,0)
	
	for a in range(-radius, radius + 1):
		for b in range(int(max(-radius, -a-radius)), int(min(radius, radius-a) + 1)):
			temp_vec = Vector3(a, b, -a-b)
			positions.append(temp_vec)
			
			var index = map_ZxZ_to_N(temp_vec.x, temp_vec.y)
			
			add_point(index, temp_vec, GODOT_FIX + costs.call_func(temp_vec + offset) + 1)
		
	for tile in positions:
		for neighbor in cube_directions:
			if has_point(map_ZxZ_to_N(tile.x + neighbor.x, tile.y + neighbor.y)):
				connect_points(map_ZxZ_to_N(tile.x, tile.y), map_ZxZ_to_N(tile.x + neighbor.x, tile.y + neighbor.y))
				
func change_radius(_radius: int, costs: FuncRef):
	if _radius < radius:
		
		for ring_radius in range(_radius + 1, radius + 1):
			var tile = cube_directions[NEIGHBORS.BOTTOM_LEFT] * ring_radius
			
			for neighbor in NEIGHBORS:
				for step in range(0, ring_radius):
					remove_point(map_ZxZ_to_N(tile.x, tile.y))
					tile = tile + cube_directions[NEIGHBORS[neighbor]]
		radius = _radius
		
	elif _radius > radius:
		for ring_radius in range(radius + 1, _radius + 1):
			var tile = cube_directions[NEIGHBORS.BOTTOM_LEFT] * ring_radius
			
			for neighbor in NEIGHBORS:
				for step in range(0, ring_radius):
					add_point(map_ZxZ_to_N(tile.x, tile.y), tile, GODOT_FIX + costs.call_func(tile + offset))
					
					for neighbor in cube_directions:
						if has_point(map_ZxZ_to_N(tile.x + neighbor.x, tile.y + neighbor.y)):
							connect_points(map_ZxZ_to_N(tile.x, tile.y), map_ZxZ_to_N(tile.x + neighbor.x, tile.y + neighbor.y))
							
					tile = tile + cube_directions[NEIGHBORS[neighbor]]
		radius = _radius
		
	pass

func update_costs(costs: FuncRef):
	for a in range(-radius, radius + 1):
		for b in range(int(max(-radius, -a-radius)), int(min(radius, radius-a) + 1)):
			var temp_vec = Vector3(a, b, -a-b)
			
			var index = map_ZxZ_to_N(temp_vec.x, temp_vec.y)
			
			set_point_weight_scale(index, GODOT_FIX + costs.call_func(temp_vec + offset))

func get_tile_path_from_to(from: Vector3, to: Vector3):
	from -= offset
	to -= offset
	
	var path = []
	if has_point(map_ZxZ_to_N(from.x, from.y)) and has_point(map_ZxZ_to_N(to.x, to.y)):
		path = get_point_path(map_ZxZ_to_N(from.x, from.y), map_ZxZ_to_N(to.x, to.y))
		
		for i in range(len(path)):
			path[i] = path[i] + offset
		
	return path
	
func get_tile_and_cost_from_to(from:Vector3, to: Vector3):
	from -= offset
	to -= offset
	
	var path = []
	var path_and_cost = {}
	
	if has_point(map_ZxZ_to_N(from.x, from.y)) and has_point(map_ZxZ_to_N(to.x, to.y)):
		path = get_point_path(map_ZxZ_to_N(from.x, from.y), map_ZxZ_to_N(to.x, to.y))
		path_and_cost["total_cost"] = 0
		for i in range(len(path)):
			path_and_cost[i] = {
				"location": path[i] + offset,
				"cost": get_point_weight_scale(map_ZxZ_to_N(path[i].x, path[i].y)) - GODOT_FIX
			}
			path_and_cost["total_cost"] += path_and_cost[i]["cost"]
		
	return path_and_cost
	
func get_positions_from_to(from: Vector3, to: Vector3):
	from -= offset
	to -= offset
	
	var tiles = get_point_path(map_ZxZ_to_N(from.x, from.y), map_ZxZ_to_N(to.x, to.y))
	var points = []
	for i in range(len(tiles)):
		points.append(Game.map_to_world(tiles[i] + offset))
		
	return points
	
func get_positions_and_costs_from_to(from: Vector3, to: Vector3):
	from -= offset
	to -= offset
	
	var path = []
	var path_and_cost = {}
	
	if has_point(map_ZxZ_to_N(from.x, from.y)) and has_point(map_ZxZ_to_N(to.x, to.y)):
		path = get_point_path(map_ZxZ_to_N(from.x, from.y), map_ZxZ_to_N(to.x, to.y))
		path_and_cost["total_cost"] = 0
		for i in range(len(path)):
			path_and_cost[i] = {
				"location": Game.map_to_world(path[i] + offset),
				"cost": get_point_weight_scale(map_ZxZ_to_N(path[i].x, path[i].y)) - GODOT_FIX
			}
			path_and_cost["total_cost"] += path_and_cost[i]["cost"]
		
	return path_and_cost
	
func get_weight_from_point(point: Vector3):
	point -= offset
	
	var index = map_ZxZ_to_N(point.x, point.y)
	if has_point(index):
		return get_point_weight_scale(index) - GODOT_FIX
	else:
		return -1
