extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$streak_label.text = str(GSession.streak) + "\n Day Streak!"
	$BackButton.pressed.connect(_on_back_pressed)
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
