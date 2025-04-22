extends Control

var auth = Firebase.Auth.auth

func _ready():
	$StartButton.pressed.connect(_on_start_game_pressed)
	$StatsButton.pressed.connect(_on_statistics_pressed)
	$ProfileButton.pressed.connect(_on_profile_pressed)
	var time = Time.get_time_dict_from_system()
	welcome_user(auth)

func welcome_user(auth):
	print("START: [WELCOME] retriving username..")
	var username = SessionProperties.username
	
	if username:
		print("[WELCOME] retrieved username from session: " + username)
		var hour = Time.get_time_dict_from_system()["hour"]
		var time_of_day = "Day"
		if  hour < 5 or hour >= 18:
			time_of_day = "Evening"
		elif hour < 12:
			time_of_day = "Morning"
		else:
			time_of_day = "Afternoon"
			
		
		$welcome_label.text = "Good " + time_of_day + ", " + username + "!"
	else:
		print("[WELCOME] failed to load username document for display")
	print("END: [WELCOME]")

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/GameSelection.tscn")
	#get_tree().change_scene_to_file("res://scenes/EndGame.tscn")
	
func _on_statistics_pressed():
	get_tree().change_scene_to_file("res://scenes/Statistics.tscn")
	
func _on_profile_pressed():
	get_tree().change_scene_to_file("res://scenes/Profile.tscn")
