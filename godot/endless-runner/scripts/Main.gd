extends Control

func _ready():
	$Button.pressed.connect(_on_start_game_pressed)

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/EndlessRunner.tscn")
