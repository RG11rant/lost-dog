extends Node2D

func _on_area_2d_body_entered(body):
	if body.has_method("refill_water"):
		body.refill_water(30)
		queue_free()
