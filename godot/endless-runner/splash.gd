extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Firebase.Auth.login_succeeded.connect(_on_login_succeeded)

	if Firebase.Auth.check_auth_file():
		print("[SPLASH] found auth file. Logging in..")
	else:
		print("[SPLASH] no auth file. Going to logged out screen..")
		get_tree().change_scene_to_file("res://scenes/LoggedOut.tscn")

func _on_login_succeeded(auth):
	print("[SPLASH] logged in")
	Firebase.Auth.save_auth(auth)
	await db_utils.init_user_properties(auth)
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
