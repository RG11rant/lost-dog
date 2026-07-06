extends Node2D

func _ready():
	add_to_group("house")

func _on_Area2D_body_entered(body):
	if body.has_method("win_game"):
		body.win_game()

