extends Control

@onready var dog = get_node("/root/main/dog")

var game_over_panel: Panel
var victory_panel: Panel

func _ready():
	create_game_over_panel()
	create_victory_panel()
	
	if dog:
		dog.water_changed.connect(_on_dog_water_changed)
		dog.food_changed.connect(_on_dog_food_changed)
		dog.game_over.connect(_on_game_over)
		dog.victory.connect(_on_victory)
		
		# Set initial values
		$water.value = dog.water
		$food.value = dog.food
	else:
		$water.value = 100
		$food.value = 100

func _process(_delta):
	$score.text = "Score : " + str(Globle.score)
	

func _on_dog_water_changed(val):
	$water.value = val

func _on_dog_food_changed(val):
	$food.value = val

func _on_dog_water_depleted():
	pass

func _on_game_over(reason):
	var vbox = game_over_panel.get_child(0)
	var reason_lbl = vbox.get_node("ReasonLabel")
	reason_lbl.text = "The dog fell asleep! (" + reason + ")"
	game_over_panel.show()

func _on_victory():
	var vbox = victory_panel.get_child(0)
	var score_lbl = vbox.get_node("ScoreLabel")
	score_lbl.text = "Bones Collected: " + str(Globle.score)
	victory_panel.show()

func _on_restart_pressed():
	Globle.score = 0
	get_tree().reload_current_scene()

func create_game_over_panel():
	game_over_panel = Panel.new()
	game_over_panel.anchor_right = 1.0
	game_over_panel.anchor_bottom = 1.0
	game_over_panel.offset_left = 0
	game_over_panel.offset_right = 0
	game_over_panel.offset_top = 0
	game_over_panel.offset_bottom = 0
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.05, 0.05, 0.9)
	game_over_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.offset_left = 0
	vbox.offset_right = 0
	vbox.offset_top = 0
	vbox.offset_bottom = 0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	
	var title = Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	vbox.add_child(title)
	
	var reason_lbl = Label.new()
	reason_lbl.name = "ReasonLabel"
	reason_lbl.text = "The dog got too tired..."
	reason_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reason_lbl.add_theme_font_size_override("font_size", 24)
	vbox.add_child(reason_lbl)
	
	var restart_btn = Button.new()
	restart_btn.text = "Try Again"
	restart_btn.custom_minimum_size = Vector2(200, 60)
	restart_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_btn)
	
	game_over_panel.add_child(vbox)
	add_child(game_over_panel)
	game_over_panel.hide()

func create_victory_panel():
	victory_panel = Panel.new()
	victory_panel.anchor_right = 1.0
	victory_panel.anchor_bottom = 1.0
	victory_panel.offset_left = 0
	victory_panel.offset_right = 0
	victory_panel.offset_top = 0
	victory_panel.offset_bottom = 0
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.15, 0.05, 0.9)
	victory_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.offset_left = 0
	vbox.offset_right = 0
	vbox.offset_top = 0
	vbox.offset_bottom = 0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	
	var title = Label.new()
	title.text = "VICTORY!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	vbox.add_child(title)
	
	var desc = Label.new()
	desc.text = "The Lost Dog Found Its Way Home!"
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 24)
	vbox.add_child(desc)
	
	var score_lbl = Label.new()
	score_lbl.name = "ScoreLabel"
	score_lbl.text = "Bones Collected: 0"
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_font_size_override("font_size", 28)
	vbox.add_child(score_lbl)
	
	var restart_btn = Button.new()
	restart_btn.text = "Play Again"
	restart_btn.custom_minimum_size = Vector2(200, 60)
	restart_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_btn)
	
	victory_panel.add_child(vbox)
	add_child(victory_panel)
	victory_panel.hide()
