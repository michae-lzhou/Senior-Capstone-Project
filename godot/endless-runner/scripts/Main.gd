extends Control

func _ready():
	$StartButton.pressed.connect(_on_start_game_pressed)
	$StatsButton.pressed.connect(_on_statistics_pressed)
	$ProfileButton.pressed.connect(_on_profile_pressed)

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/GameSelection.tscn")
	
func _on_statistics_pressed():
	get_tree().change_scene_to_file("res://scenes/Statistics.tscn")
	
func _on_profile_pressed():
	get_tree().change_scene_to_file("res://scenes/Profile.tscn")
