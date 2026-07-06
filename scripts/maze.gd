extends Node2D

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {
	Vector2i(0, -1): N,
	Vector2i(1, 0): E, 
	Vector2i(0, 1): S,
	Vector2i(-1, 0): W
}

var tile_size = 512 # tile size (in pixels)
var width = 10 # width of map (in tiles)
var height = 10 # height of map (in tiles)

# get a reference to the map for convenience
@onready var Map = $grass
var door = preload("res://sceens/house.tscn")
var bone = preload("res://sceens/bones.tscn")
var water_puddle = preload("res://sceens/waterBowl.tscn")
var enemy_catcher = preload("res://sceens/enemy_catcher.tscn")
var enemy_cat = preload("res://sceens/enemy_cat.tscn")
var enemy_vacuum = preload("res://sceens/enemy_vacuum.tscn")

var rng = RandomNumberGenerator.new()
var exit_cell: Vector2i = Vector2i(-1, -1)
var stack = []

func _ready():
	randomize()
	if Map and Map.tile_set:
		tile_size = Map.tile_set.tile_size.x
	else:
		tile_size = 512
		
	$Camera2D.limit_bottom = tile_size * height
	$Camera2D.limit_right = tile_size * width
	
	make_maze()
	make_end()
	make_bones()
	make_puddles()
	make_enemies()
	
func check_neighbors(cell: Vector2i, unvisited: Array) -> Array:
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list
	
func make_maze():
	var unvisited = []  # array of unvisited tiles
	stack = []
	# fill the map with solid tiles
	Map.clear()
	for x in range(width):
		for y in range(height):
			var cell = Vector2i(x, y)
			unvisited.append(cell)
			# Godot 4 uses set_cell(layer, coords, source_id, atlas_coords)
			Map.set_cell(0, cell, N|E|S|W, Vector2i(0, 0))
			
	var current = Vector2i(0, 0)
	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from *both* cells
			var dir = next - current
			var current_walls = Map.get_cell_source_id(0, current) - cell_walls[dir]
			var next_walls = Map.get_cell_source_id(0, next) - cell_walls[-dir]
			Map.set_cell(0, current, current_walls, Vector2i(0, 0))
			Map.set_cell(0, next, next_walls, Vector2i(0, 0))
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()

func make_end():
	rng.randomize()
	var exit_x = rng.randi_range(width - 2, width - 1)
	var exit_y = rng.randi_range(height - 2, height - 1)
	exit_cell = Vector2i(exit_x, exit_y)
	
	var door_out = door.instantiate()
	var door_pos = Vector2((exit_x * tile_size) + (tile_size / 2.0), (exit_y * tile_size) + (tile_size / 2.0))
	door_out.position = door_pos
	add_child(door_out)

func make_bones():
	rng.randomize()
	for x in range(width):
		for y in range(height):
			var cell = Vector2i(x, y)
			if cell == Vector2i(0, 0) or cell == exit_cell:
				continue
			# 30% chance to spawn a bone
			if rng.randf() < 0.3:
				var bony = bone.instantiate()
				var bone_pos = Vector2((x * tile_size) + (tile_size / 2.0), (y * tile_size) + (tile_size / 2.0))
				bony.position = bone_pos
				bony.add_to_group("bones")
				add_child(bony)

func make_puddles():
	rng.randomize()
	for x in range(width):
		for y in range(height):
			var cell = Vector2i(x, y)
			if cell == Vector2i(0, 0) or cell == exit_cell:
				continue
			# 15% chance to spawn a water puddle
			if rng.randf() < 0.15:
				var puddle = water_puddle.instantiate()
				var puddle_pos = Vector2((x * tile_size) + (tile_size / 2.0), (y * tile_size) + (tile_size / 2.0))
				puddle.position = puddle_pos
				puddle.add_to_group("puddles")
				add_child(puddle)

func make_enemies():
	rng.randomize()
	var occupied_cells = {Vector2i(0, 0): true, exit_cell: true}
	
	# Spawn 2 Sleepy Dog Catchers
	var catchers_spawned = 0
	while catchers_spawned < 2:
		var x = rng.randi_range(2, width - 1)
		var y = rng.randi_range(2, height - 1)
		var cell = Vector2i(x, y)
		if not occupied_cells.has(cell):
			occupied_cells[cell] = true
			var catcher = enemy_catcher.instantiate()
			catcher.position = Vector2(x * tile_size + 256.0, y * tile_size + 256.0)
			add_child(catcher)
			catchers_spawned += 1
			
	# Spawn 3 Alley Cats
	var cats_spawned = 0
	while cats_spawned < 3:
		var x = rng.randi_range(1, width - 1)
		var y = rng.randi_range(1, height - 1)
		var cell = Vector2i(x, y)
		if not occupied_cells.has(cell):
			var cell_mask = Map.get_cell_source_id(0, cell)
			var open_paths = 0
			if (cell_mask & 1) == 0: open_paths += 1
			if (cell_mask & 2) == 0: open_paths += 1
			if (cell_mask & 4) == 0: open_paths += 1
			if (cell_mask & 8) == 0: open_paths += 1
			
			if open_paths >= 2: # blocks key pathways
				occupied_cells[cell] = true
				var cat = enemy_cat.instantiate()
				cat.position = Vector2(x * tile_size + 256.0, y * tile_size + 256.0)
				add_child(cat)
				cats_spawned += 1

	# Spawn 2 Vacuum Cleaners
	var vacuums_spawned = 0
	while vacuums_spawned < 2:
		var x = rng.randi_range(1, width - 2)
		var y = rng.randi_range(1, height - 2)
		var cell = Vector2i(x, y)
		
		if not occupied_cells.has(cell):
			var cell_mask = Map.get_cell_source_id(0, cell)
			var is_horizontal = (cell_mask & 2) == 0
			var is_vertical = (cell_mask & 4) == 0
			
			if is_horizontal or is_vertical:
				occupied_cells[cell] = true
				var vac = enemy_vacuum.instantiate()
				var dir = Vector2i(1, 0) if is_horizontal else Vector2i(0, 1)
				
				# Check if the adjacent cell is also clear in this direction
				var next_cell = cell + dir
				var next_mask = Map.get_cell_source_id(0, next_cell)
				var path_clear = false
				if is_horizontal and (next_mask & 2) == 0:
					path_clear = true
				elif is_vertical and (next_mask & 4) == 0:
					path_clear = true
					
				if path_clear:
					occupied_cells[next_cell] = true
					vac.setup_patrol(cell, dir, 2)
					add_child(vac)
					vacuums_spawned += 1
