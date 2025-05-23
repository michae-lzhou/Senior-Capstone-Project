extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubmitButton.pressed.connect(_on_submit_button_pressed)
	$BackButton.pressed.connect(_on_back_button_pressed)
	$forgot_button.pressed.connect(_on_forgot_button_pressed)
	
	Firebase.Auth.login_succeeded.connect(_on_login_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	
	if Firebase.Auth.check_auth_file():
		print("[LOGIN] found auth file. Logging in..")
		$login_success_label.text = "Login successful"

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LoggedOut.tscn")

func _on_submit_button_pressed() -> void:
	print("[LOGIN] logging in..")
	$login_success_label.text = "Logging in.."
	var email = $email_ledit.text.strip_edges()
	var password = $pass_ledit.text
	Firebase.Auth.login_with_email_and_password(email, password)

func _on_login_succeeded(auth):
	$login_success_label.text = "Login successful!"
	print("[LOGIN] logged in")
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("res://scenes/Splash.tscn")
	
	#await db_utils.init_user_properties(auth)
	#get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

func on_login_failed(error_code, message):
	print("[LOGIN] FAILED: " + str(error_code))
	print(str(message))
	
	var message_r = str(message)
	if message_r == "INVALID_LOGIN_CREDENTIALS":
		message_r = "Invalid username or incorect password"
	
	$login_success_label.text = "Login failed: " + message_r

func _on_forgot_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ForgotPwd.tscn")
