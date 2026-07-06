extends Node2D

var floating_text = preload("res://sceens/floatingText.tscn")
var reset_timer = 0.0

@onready var status_lbl = $Label

func _ready():
	add_to_group("cats")
	status_lbl.text = "Hiss! >:3"

func _draw():
	# Draw cat ears
	draw_colored_polygon(PackedVector2Array([Vector2(-16, -10), Vector2(-22, -26), Vector2(-4, -18)]), Color(0.6, 0.3, 0.7))
	draw_colored_polygon(PackedVector2Array([Vector2(4, -18), Vector2(22, -26), Vector2(16, -10)]), Color(0.6, 0.3, 0.7))
	
	# Draw head
	draw_circle(Vector2(0, 0), 18.0, Color(0.5, 0.2, 0.6)) # Purple cat!
	
	# Draw glowing green eyes
	draw_circle(Vector2(-6, -4), 4.0, Color(0.2, 0.9, 0.2))
	draw_line(Vector2(-6, -7), Vector2(-6, -1), Color(0, 0, 0), 1.5)
	draw_circle(Vector2(6, -4), 4.0, Color(0.2, 0.9, 0.2))
	draw_line(Vector2(6, -7), Vector2(6, -1), Color(0, 0, 0), 1.5)
	
	# Draw little pink nose
	draw_colored_polygon(PackedVector2Array([Vector2(-3, 2), Vector2(3, 2), Vector2(0, 5)]), Color(0.9, 0.5, 0.6))
	
	# Draw whiskers
	draw_line(Vector2(-10, 4), Vector2(-22, 2), Color(0.1, 0.1, 0.1), 1.2)
	draw_line(Vector2(-10, 7), Vector2(-23, 8), Color(0.1, 0.1, 0.1), 1.2)
	draw_line(Vector2(10, 4), Vector2(22, 2), Color(0.1, 0.1, 0.1), 1.2)
	draw_line(Vector2(10, 7), Vector2(23, 8), Color(0.1, 0.1, 0.1), 1.2)

func _process(delta):
	queue_redraw()
	
	if reset_timer > 0.0:
		reset_timer -= delta
		if reset_timer <= 0.0:
			status_lbl.text = "Hiss! >:3"

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		var push_dir = body.global_position - global_position
		if push_dir == Vector2.ZERO:
			push_dir = Vector2.UP
		body.take_damage(15, push_dir)
		status_lbl.text = "CLAW! HISS!"
		reset_timer = 1.5

func on_dog_bark(bark_pos: Vector2):
	var dist = global_position.distance_to(bark_pos)
	if dist <= 350.0: # If dog barks within 350 pixels, cat is scared off!
		# Spawn scared text
		var textF = floating_text.instantiate()
		textF.text_dis = "Screech! *Scram!*"
		textF.global_position = global_position
		get_parent().add_child(textF)
		queue_free()
