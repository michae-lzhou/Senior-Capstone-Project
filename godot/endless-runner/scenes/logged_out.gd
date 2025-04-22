extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LoginButton.pressed.connect(_on_login_button_pressed)
	$SignupButton.pressed.connect(_on_signup_button_pressed)
	
	#Firebase.Auth.login_succeeded.connect(_on_login_succeeded)

	#if Firebase.Auth.check_auth_file():
		#print("[LOGGED OUT] found auth file. Logging in..")

func _on_login_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Login.tscn")

#func _on_login_succeeded(auth):
	#$login_success_label.text = "Login successful!"
	#print("[LOGGED OUT] logged in")
	#Firebase.Auth.save_auth(auth)
	#await db_utils.init_user_properties(auth)
	#get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

func _on_signup_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Signup.tscn")
