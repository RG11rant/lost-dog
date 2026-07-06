extends Node2D

var start_pos: Vector2 = Vector2.ZERO
var limit_min: Vector2 = Vector2.ZERO
var limit_max: Vector2 = Vector2.ZERO
var patrol_dir: Vector2 = Vector2.RIGHT
var speed = 180.0
var moving_to_max = true

func _ready():
	add_to_group("vacuums")

func setup_patrol(grid_start: Vector2i, grid_dir: Vector2i, length: int):
	# Calculate coordinates
	var tile_size = 512.0
	start_pos = Vector2(grid_start.x * tile_size + 256.0, grid_start.y * tile_size + 256.0)
	global_position = start_pos
	
	patrol_dir = Vector2(grid_dir).normalized()
	
	limit_min = start_pos
	limit_max = start_pos + patrol_dir * (length * tile_size)
	
	# Swap if limits are inverted
	if limit_min.x > limit_max.x or limit_min.y > limit_max.y:
		var temp = limit_min
		limit_min = limit_max
		limit_max = temp
		
	moving_to_max = true

func _draw():
	# Draw canister vacuum body
	draw_rect(Rect2(-22, -15, 44, 30), Color(0.4, 0.4, 0.45), true) # Gray/blue body
	draw_rect(Rect2(-22, -15, 44, 30), Color(0.15, 0.15, 0.15), false, 2.5) # Border
	
	# Draw funny red bumper
	draw_rect(Rect2(-24, 8, 48, 6), Color(0.9, 0.2, 0.2), true)
	
	# Draw plastic wheels
	draw_circle(Vector2(-12, 15), 7.0, Color(0.1, 0.1, 0.1))
	draw_circle(Vector2(12, 15), 7.0, Color(0.1, 0.1, 0.1))
	
	# Googly eyes
	draw_circle(Vector2(-8, -5), 6.0, Color(1, 1, 1))
	draw_circle(Vector2(-8, -5), 2.5, Color(0, 0, 0))
	draw_circle(Vector2(8, -5), 6.0, Color(1, 1, 1))
	draw_circle(Vector2(8, -5), 2.5, Color(0, 0, 0))
	
	# Hose connection/nozzle
	var hose_side = 22.0 if patrol_dir.x >= 0 else -22.0
	draw_line(Vector2(hose_side, 5), Vector2(hose_side + patrol_dir.x * 12.0, 12), Color(0.2, 0.2, 0.2), 6.0)

func _process(_delta):
	queue_redraw()

func _physics_process(delta):
	if limit_min == limit_max:
		return # No patrol range set
		
	var target = limit_max if moving_to_max else limit_min
	if global_position.distance_to(target) > 5.0:
		global_position = global_position.move_toward(target, speed * delta)
	else:
		global_position = target
		moving_to_max = !moving_to_max

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		# Calculate knockback direction
		var push_dir = body.global_position - global_position
		if push_dir == Vector2.ZERO:
			push_dir = patrol_dir
		body.take_damage(10, push_dir)
