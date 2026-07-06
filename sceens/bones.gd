extends Node2D

func _ready():
	$Area2D/AnimatedSprite2D.play("spine")

func _on_Area2D_body_entered(body):
	if body.has_method("refill_food"):
		body.refill_food(20)
		Globle.score += 20
		queue_free()
