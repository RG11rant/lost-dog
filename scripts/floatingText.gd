extends Position2D

onready var label = get_node("Label")
onready var tween = get_node("Tween")
var veloc = Vector2(0, 0)
var text_dis = "BARK"

# Called when the node enters the scene tree for the first time.
func _ready():
	label.set_text(text_dis)
	randomize()
	var side_move = randi() % 121 - 60
	veloc = Vector2(side_move, 55)
	tween.interpolate_property(self, 'scale', scale, Vector2(1, 1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1, 1), Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()

func _on_Tween_tween_all_completed():
	self.queue_free()


func _process(delta):
	position -= veloc * delta
