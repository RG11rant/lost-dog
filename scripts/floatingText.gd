extends Marker2D

@onready var label = get_node("Label")
var veloc = Vector2(0, 0)
var text_dis = "BARK"

# Called when the node enters the scene tree for the first time.
func _ready():
	label.set_text(text_dis)
	randomize()
	var side_move = randi() % 121 - 60
	veloc = Vector2(side_move, 30)
	
	scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 1.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT).set_delay(2.2)
	tween.finished.connect(queue_free)

func _process(delta):
	position -= veloc * delta

