extends CharacterBody2D

var pee = preload("res://sceens/pee.tscn")
var floating_text = preload("res://sceens/floatingText.tscn")
var pe
var water : int = 100
var food : int = 100
var idel_pos = 1

var max_speed : int = 250
var accel : int = 800
var speed : int = 0
var grow = 1.0
var delay = 0.0
var flabel = 50
var move_dir = 0.0
var moving : bool = false
var action : int = 0
var do_one = false
var bark_time = false
var is_dead : bool = false

var pos : Vector2 = Vector2()
var click_pos : Vector2 = Vector2()

signal water_changed(value)
signal food_changed(value)
signal water_depleted
signal game_over(reason)
signal victory

@onready var sprite : Sprite2D = get_node("Sprite2D")

var start_pos : Vector2

func _ready():
	add_to_group("player")
	start_pos = global_position
	emit_signal("water_changed", water)
	emit_signal("food_changed", food)

func _process(delta):
	if is_dead:
		return
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

func _physics_process(delta):
	if not is_dead:
		# Deplete food slowly over time
		var food_drain = 1.0 if not moving else 2.5
		deplete_food(delta * food_drain)
		
		# Deplete water when moving
		if moving:
			deplete_water(delta * 4.0)
			
		Movementloop(delta)

func deplete_water(amount: float):
	if is_dead: return
	water = max(0, water - int(amount))
	emit_signal("water_changed", water)
	if water == 0:
		emit_signal("water_depleted")
		die("Dehydrated!")

func deplete_food(amount: float):
	if is_dead: return
	food = max(0, food - int(amount))
	emit_signal("food_changed", food)
	if food == 0:
		die("Starved!")

func refill_water(amount: int):
	if is_dead: return
	water = min(100, water + amount)
	emit_signal("water_changed", water)
	var textF = floating_text.instantiate()
	textF.text_dis = "Slurp! +%d Water" % amount
	add_child(textF)

func refill_food(amount: int):
	if is_dead: return
	food = min(100, food + amount)
	emit_signal("food_changed", food)
	var textF = floating_text.instantiate()
	textF.text_dis = "Nom Nom! +%d Food" % amount
	add_child(textF)

func die(reason: String):
	is_dead = true
	moving = false
	action = 0
	$AnimationPlayer.stop()
	$Sprite2D.frame = 14 # Tired/listening frame
	emit_signal("game_over", reason)

func win_game():
	if is_dead: return
	is_dead = true
	moving = false
	action = 0
	$AnimationPlayer.play("bark")
	emit_signal("victory")

func take_damage(amount: int, push_dir: Vector2):
	if is_dead: return
	
	# Deplete resources (minimum 0 handles are already in deplete_food/deplete_water)
	deplete_food(amount)
	deplete_water(amount)
	
	# Visual ouch text
	var textF = floating_text.instantiate()
	textF.text_dis = "Ouch!"
	add_child(textF)
	
	# Knockback
	if push_dir != Vector2.ZERO:
		moving = true
		click_pos = global_position + push_dir.normalized() * 128.0
		# Prevent moving outside limits
		var map_width = 5120.0
		var map_height = 5120.0
		click_pos.x = clamp(click_pos.x, 50.0, map_width - 50.0)
		click_pos.y = clamp(click_pos.y, 50.0, map_height - 50.0)

func reset_to_start():
	if is_dead: return
	moving = false
	global_position = start_pos
	click_pos = start_pos
	var textF = floating_text.instantiate()
	textF.text_dis = "Caught! back to start!"
	add_child(textF)

func bark_animation(delta):
	$AnimationPlayer.play("bark")
	delay += delta
	if delay > 1.5: # shorten bark action lock to 1.5 seconds for snappier play
		delay = 0
		action = 0

func pee_animation():
	if do_one == true:
		deplete_water(10)
		$Sprite2D.frame = 12
		pe = pee.instantiate()
		get_parent().add_child(pe)
		pe.position = global_position
		flabel = 40
		grow = 0.1
		do_one = false
		
		var textF = floating_text.instantiate()
		textF.text_dis = "Scwinkle!"
		add_child(textF)
		
	if grow < 1.0:
		pe.scale = Vector2(grow, grow)
		grow += 0.05
	else:
		action = 0

func listen_animation():
	if do_one == true:
		$Sprite2D.frame = 14
		do_one = false
		flabel = 0
	flabel += 1
	if flabel > 60: # 1 second lock
		action = 0
		flabel = 0

func sniff_animation():
	if do_one == true:
		$Sprite2D.frame = 15
		do_one = false
		flabel = 0
	flabel += 1
	if flabel > 60: # 1 second lock
		action = 0
		flabel = 0

func walk_animation():
	if moving == true:
		if move_dir > -45 and move_dir < 45:
			$AnimationPlayer.play("walkRight")
			idel_pos = 7
		elif move_dir > 45 and move_dir < 135:
			$AnimationPlayer.play("walkDown")
			idel_pos = 1
		elif move_dir > -135 and move_dir < -45:
			$AnimationPlayer.play("walkup")
			idel_pos = 10
		else:
			$AnimationPlayer.play("walkLift")
			idel_pos = 4
	else:
		$AnimationPlayer.stop()
		$Sprite2D.frame = idel_pos

func Movementloop(dalta):
	if moving == false:
		speed = 0
	else:
		speed += accel * dalta
		if speed > max_speed:
			speed = max_speed
			
	if position.distance_to(click_pos) > 10:
		pos = position.direction_to(click_pos) * speed
		move_dir = rad_to_deg(position.angle_to_point(click_pos))
		velocity = pos
		move_and_slide()
	else:
		moving = false

func get_direction_string(dir: Vector2) -> String:
	var angle = rad_to_deg(dir.angle())
	if angle >= -22.5 and angle < 22.5:
		return "East"
	elif angle >= 22.5 and angle < 67.5:
		return "South-East"
	elif angle >= 67.5 and angle < 112.5:
		return "South"
	elif angle >= 112.5 and angle < 157.5:
		return "South-West"
	elif angle >= 157.5 or angle < -157.5:
		return "West"
	elif angle >= -157.5 and angle < -112.5:
		return "North-West"
	elif angle >= -112.5 and angle < -67.5:
		return "North"
	else:
		return "North-East"

func _on_bark_pressed():
	if action == 0 and not is_dead:
		action = 2
		flabel = 49
		delay = 0.0
		bark_time = true
		
		# Alert catchers and cats
		get_tree().call_group("catchers", "on_dog_bark", global_position)
		get_tree().call_group("cats", "on_dog_bark", global_position)
		
		# Clue text
		var house_node = get_tree().get_first_node_in_group("house")
		var clue_text = "Bark! Bark!"
		if house_node:
			var dist = global_position.distance_to(house_node.global_position)
			clue_text = "Home is %d steps away" % int(dist / 32.0)
			
		var textF = floating_text.instantiate()
		textF.text_dis = clue_text
		add_child(textF)

func _on_mark_pressed():
	if action == 0 and not moving and not is_dead:
		if water >= 10:
			action = 1
			do_one = true
		else:
			var textF = floating_text.instantiate()
			textF.text_dis = "Need water to mark!"
			add_child(textF)

func _on_sniff_pressed():
	if action == 0 and not is_dead:
		action = 4
		do_one = true
		
		# Sniff out closest bone
		var bones = get_tree().get_nodes_in_group("bones")
		var clue_text = "Sniff... Nothing here."
		if bones.size() > 0:
			var closest_bone = bones[0]
			var min_dist = global_position.distance_to(closest_bone.global_position)
			for b in bones:
				var dist = global_position.distance_to(b.global_position)
				if dist < min_dist:
					min_dist = dist
					closest_bone = b
			var rel_dir = global_position.direction_to(closest_bone.global_position)
			clue_text = "Bone is " + get_direction_string(rel_dir)
			
		var textF = floating_text.instantiate()
		textF.text_dis = clue_text
		add_child(textF)

func _on_listen_pressed():
	if action == 0 and not is_dead:
		action = 3
		do_one = true
		
		# Listen for the house
		var house_node = get_tree().get_first_node_in_group("house")
		var clue_text = "Listen... Quiet."
		if house_node:
			var rel_dir = global_position.direction_to(house_node.global_position)
			clue_text = "Hear home to the " + get_direction_string(rel_dir)
			
		var textF = floating_text.instantiate()
		textF.text_dis = clue_text
		add_child(textF)

func _on_Control_gui_input(event):
	if action == 0 and not is_dead:
		if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
			moving = true
			click_pos = get_global_mouse_position()
