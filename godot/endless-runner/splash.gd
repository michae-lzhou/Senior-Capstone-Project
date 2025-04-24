extends Control

class_name splash

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Firebase.Auth.login_succeeded.connect(_on_login_succeeded)
	Firebase.Auth.login_failed.connect(_on_login_failed)

	if Firebase.Auth.check_auth_file():
		print("[SPLASH] found auth file. Logging in..")
	else:
		print("[SPLASH] no auth file. Going to logged out screen..")
		get_tree().change_scene_to_file("res://scenes/LoggedOut.tscn")

func _on_login_succeeded(auth):
	print("[SPLASH] logged in")
	Firebase.Auth.save_auth(auth)
	await db_utils.init_user_properties(auth, $loading_label)
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

func _on_login_failed(error_code, message):
	print("[SPLASH] FAILED: " + str(error_code))
	print(str(message))
	get_tree().change_scene_to_file("res://scenes/Login.tscn")
	
func change_label(content : String):
	$loading_label.text = content
