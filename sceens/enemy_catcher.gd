extends Node2D

enum State { SLEEPING, WANDERING, INVESTIGATING, CHASING }

var current_state = State.SLEEPING
var current_cell: Vector2i = Vector2i(-1, -1)
var target_cell: Vector2i = Vector2i(-1, -1)
var target_pos: Vector2 = Vector2.ZERO
var path: Array = []

var speed = 120.0
var target_player: CharacterBody2D = null
var bark_investigate_pos: Vector2 = Vector2.ZERO
var investigate_timer = 0.0

@onready var Map = get_parent().get_node("grass")
@onready var status_lbl = $Label

func _ready():
	add_to_group("catchers")
	# Determine initial grid cell based on coordinates
	current_cell = Vector2i(global_position / 512.0)
	global_position = Vector2(current_cell.x * 512 + 256, current_cell.y * 512 + 256)
	target_cell = current_cell
	target_pos = global_position
	update_label()

func _draw():
	# Draw net handle
	draw_line(Vector2(0, 0), Vector2(25, -25), Color(0.6, 0.4, 0.2), 4.0)
	# Draw net bag
	draw_circle(Vector2(25, -25), 15.0, Color(0.8, 0.8, 1.0, 0.5))
	draw_arc(Vector2(25, -25), 15.0, 0, TAU, 32, Color(0.3, 0.3, 0.3), 3.0)
	
	# Draw goofy body/head
	draw_circle(Vector2(0, 0), 22.0, Color(0.2, 0.5, 0.9)) # Blue clothes/skin
	
	# Draw funny white eyes
	draw_circle(Vector2(-8, -4), 5.0, Color(1.0, 1.0, 1.0))
	draw_circle(Vector2(-8, -4), 2.0, Color(0.0, 0.0, 0.0))
	draw_circle(Vector2(8, -4), 5.0, Color(1.0, 1.0, 1.0))
	draw_circle(Vector2(8, -4), 2.0, Color(0.0, 0.0, 0.0))
	
	# Draw happy/goofy smile
	draw_arc(Vector2(0, 4), 6.0, 0.1, PI - 0.1, 16, Color(0.1, 0.1, 0.1), 3.0)
	
	# Draw a yellow catcher hat
	draw_circle(Vector2(0, -18), 12.0, Color(0.9, 0.7, 0.1))
	draw_line(Vector2(-20, -16), Vector2(20, -16), Color(0.9, 0.7, 0.1), 4.0)

func _process(delta):
	queue_redraw()

func _physics_process(delta):
	# If sleeping, do nothing unless player is detected
	if current_state == State.SLEEPING:
		return
		
	# If investigating and arrived at bark location
	if current_state == State.INVESTIGATING and current_cell == target_cell and path.size() == 0:
		investigate_timer += delta
		status_lbl.text = "Huh? (*sniff*)"
		if investigate_timer > 2.0:
			investigate_timer = 0.0
			current_state = State.WANDERING
			update_label()
		return
		
	# Handle movement towards target position
	if global_position.distance_to(target_pos) > 5.0:
		global_position = global_position.move_toward(target_pos, speed * delta)
	else:
		global_position = target_pos
		current_cell = target_cell
		
		# Decide next step once we reach the current target cell
		choose_next_action()

func choose_next_action():
	if current_state == State.CHASING and target_player:
		# Track the player
		var player_cell = Vector2i(target_player.global_position / 512.0)
		if player_cell != current_cell:
			path = find_path(current_cell, player_cell)
			if path.size() > 0:
				target_cell = path[0]
				path.remove_at(0)
			else:
				target_cell = current_cell
		else:
			target_cell = current_cell
			
	elif current_state == State.INVESTIGATING:
		if path.size() > 0:
			target_cell = path[0]
			path.remove_at(0)
		else:
			# Arrived at bark source
			target_cell = current_cell
			
	else: # State.WANDERING
		var neighbors = get_open_neighbors(current_cell)
		if neighbors.size() > 0:
			target_cell = neighbors[randi() % neighbors.size()]
		else:
			target_cell = current_cell
			
	target_pos = Vector2(target_cell.x * 512 + 256, target_cell.y * 512 + 256)

func on_dog_bark(bark_pos: Vector2):
	if current_state == State.CHASING:
		return # chasing player is higher priority than noise
		
	# Wake up if sleeping and find path to the bark
	var start_cell = current_cell
	var end_cell = Vector2i(bark_pos / 512.0)
	
	var dist = start_cell.distance_to(end_cell)
	if dist <= 5: # Hear bark if within 5 cells
		current_state = State.INVESTIGATING
		investigate_timer = 0.0
		path = find_path(start_cell, end_cell)
		if path.size() > 0:
			target_cell = path[0]
			path.remove_at(0)
			target_pos = Vector2(target_cell.x * 512 + 256, target_cell.y * 512 + 256)
		update_label()

func get_open_neighbors(cell: Vector2i) -> Array:
	if not Map:
		return []
	var cell_mask = Map.get_cell_source_id(0, cell)
	if cell_mask == -1:
		return []
		
	var list = []
	# Check cell wall bits (1=N, 2=E, 4=S, 8=W)
	if (cell_mask & 1) == 0 and cell.y > 0:
		list.append(cell + Vector2i(0, -1))
	if (cell_mask & 2) == 0 and cell.x < 9:
		list.append(cell + Vector2i(1, 0))
	if (cell_mask & 4) == 0 and cell.y < 9:
		list.append(cell + Vector2i(0, 1))
	if (cell_mask & 8) == 0 and cell.x > 0:
		list.append(cell + Vector2i(-1, 0))
	return list

func find_path(start: Vector2i, end: Vector2i) -> Array:
	if not Map:
		return []
	# BFS search algorithm for grid path
	var queue = [start]
	var came_from = {start: start}
	var visited = {start: true}
	
	while queue.size() > 0:
		var current = queue.pop_front()
		if current == end:
			break
			
		var neighbors = get_open_neighbors(current)
		for neighbor in neighbors:
			if not visited.has(neighbor):
				visited[neighbor] = true
				came_from[neighbor] = current
				queue.append(neighbor)
				
	if not came_from.has(end):
		return []
		
	# Reconstruct path back
	var reconstructed_path = []
	var curr = end
	while curr != start:
		reconstructed_path.append(curr)
		curr = came_from[curr]
	reconstructed_path.reverse()
	return reconstructed_path

func update_label():
	match current_state:
		State.SLEEPING:
			status_lbl.text = "Sleeping Zzz"
			status_lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
		State.WANDERING:
			status_lbl.text = "Patrolling"
			status_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		State.INVESTIGATING:
			status_lbl.text = "What was that?!"
			status_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.1))
		State.CHASING:
			status_lbl.text = "Come back puppy!"
			status_lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))

# Player enters sight area
func _on_sight_area_body_entered(body):
	if body.is_in_group("player"):
		target_player = body
		current_state = State.CHASING
		update_label()

# Player leaves sight area
func _on_sight_area_body_exited(body):
	if body.is_in_group("player"):
		target_player = null
		if current_state == State.CHASING:
			current_state = State.WANDERING
			update_label()

# Catches player
func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and body.has_method("reset_to_start"):
		# Catch!
		body.reset_to_start()
		# Drop resources penalty
		if body.has_method("deplete_food"):
			body.deplete_food(25)
			body.deplete_water(25)
		
		# Look around contentedly
		current_state = State.WANDERING
		update_label()
