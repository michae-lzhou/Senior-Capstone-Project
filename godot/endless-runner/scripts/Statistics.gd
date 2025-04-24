extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var streak = GSession.streak
	if streak >= 100:
		$streak_label.text = str(GSession.streak) + "\n 🔥🔥 Day Streak!!! 🔥🔥"
	elif streak >= 10:
		$streak_label.text = str(GSession.streak) + "\n 🔥 Day Streak!! 🔥"
	else:
		$streak_label.text = str(GSession.streak) + "\n Day Streak!"
	$BackButton.pressed.connect(_on_back_pressed)
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
