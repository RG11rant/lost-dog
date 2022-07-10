extends KinematicBody2D

var pee = preload("res://sceens/pee.tscn")
var floating_text = preload("res://sceens/floatingText.tscn")
var pe
var water : int  = 100
var food : int = 0
var idel_pos = 1;

var max_speed : int = 200
var accel : int = 600
var speed : int = 0
var grow = 1
var delay = 0
var flabel = 50
var move_dir
var moving : bool = false
var action : int = 0
var do_one = false
var bark_time = false

var pos : Vector2 = Vector2()
var click_pos : Vector2 = Vector2()

onready var sprite : Sprite = get_node("Sprite")

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		moving = true
		click_pos = get_global_mouse_position()

func _process(delta):
	if action == 1:
		pee_animation()
	elif action == 2:
		bark_animation(delta)
	elif action == 3:
		listen_animation()
	elif action == 4:
		sniff_animation()
	else:
		walk_animation()

func bark_animation(delta):
	$AnimationPlayer.play("bark")
	delay += delta
	flabel += 1
	if flabel == 50:
		var textF = floating_text.instance()
		textF.text_dis = "Bark"
		add_child(textF)
		flabel = 0
	if delay > 3:
		delay = 0
		action = 0

func pee_animation():
	if do_one == true:
		$Sprite.frame = 12
		pe = pee.instance()
		get_parent().add_child(pe)
		pe.position = global_position
		grow = 0
		do_one = false
	flabel += 1
	if flabel == 50:
		var textF = floating_text.instance()
		textF.text_dis = "Scwinkle"
		add_child(textF)
		flabel = 0
	if grow < 1:
		pe.scale.x = grow
		pe.scale.y = grow
		grow += 0.01
	else:
		action = 0

func _physics_process(delta):
	Movementloop(delta)

func listen_animation():
	if do_one == true:
		$Sprite.frame = 14
		var textF = floating_text.instance()
		textF.text_dis = "Listening"
		add_child(textF)
		do_one = false
	flabel += 1
	if flabel > 150:
		action = 0
		flabel = 0

func sniff_animation():
	if do_one == true:
		$Sprite.frame = 15
		var textF = floating_text.instance()
		textF.text_dis = "Sniff"
		add_child(textF)
		do_one = false
	flabel += 1
	if flabel > 150:
		action = 0
		flabel = 0

func walk_animation():
	if moving == true:
		if move_dir > -45 and move_dir < 45:
			$AnimationPlayer.play("walkRight")
			idel_pos = 7
		if move_dir > 45 and move_dir < 135:
			$AnimationPlayer.play("walkDown")
			idel_pos = 1
		if move_dir > -135 and move_dir < -45:
			$AnimationPlayer.play("walkup")
			idel_pos = 10
		if move_dir > -180 and move_dir < -135:
			$AnimationPlayer.play("walkLift")
			idel_pos = 4
		if move_dir > 135 and move_dir < 180:
			$AnimationPlayer.play("walkLift")
			idel_pos = 4
	else:
		$AnimationPlayer.stop()
		$Sprite.frame = idel_pos

func Movementloop(dalta):
	if moving == false:
		speed = 0
	else:
		speed += accel * dalta
		if speed > max_speed:
			speed = max_speed
	pos = position.direction_to(click_pos) * speed
	move_dir = rad2deg(click_pos.angle_to_point(position))
	if position.distance_to(click_pos) > 5:
		pos = move_and_slide(pos)
	else:
		moving = false

func _on_bark_pressed():
	action = 2
	flabel = 49
	bark_time = true

func _on_mark_pressed():
	action = 1
	do_one = true

func _on_sniff_pressed():
	action = 4
	do_one = true

func _on_listen_pressed():
	action = 3
	do_one = true
