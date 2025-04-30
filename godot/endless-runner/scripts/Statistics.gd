extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var streak = GSession.streak
	if streak > 99:
		$streak_label.text = "🔥🔥 " + str(GSession.streak) + " 🔥🔥" + "\nDay Streak!!!"
	elif streak > 9:
		$streak_label.text = "🔥 " + str(GSession.streak) + " 🔥" + "\nDay Streak!!"
	elif streak > 4:
		$streak_label.text = "🔥 " + str(GSession.streak) + " 🔥" + "\nDay Streak!"
	else:
		$streak_label.text = str(GSession.streak) + "\n Day Streak"
	$BackButton.pressed.connect(_on_back_pressed)
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
