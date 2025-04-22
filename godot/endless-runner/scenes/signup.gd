extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RegisterButton.pressed.connect(_on_register_button_pressed)
	$BackButton.pressed.connect(_on_back_button_pressed)
	
	Firebase.Auth.signup_succeeded.connect(_on_signup_succeeded)
	Firebase.Auth.signup_failed.connect(_on_signup_failed)

func _on_register_button_pressed():
	print("[SIGNUP] signing up..")
	$register_success_label.text = "Signing up.."
	$username_success_label.text = ""

	var email = $email_ledit.text.strip_edges()
	var password = $pass_ledit.text
	var username :String = $name_ledit.text.strip_edges()
	
	$pass_ledit.text = ""
	
	if email == "" or password == "":
		$register_success_label.text = "Email and password cannot be empty!"
		return
	
	if username == "":
		$register_success_label.text = "Please add a display name"
		return
	
	if username.length() > 17:
		$register_success_label.text = "Please shorten username to less than 18 characters"
		return
		
	Firebase.Auth.signup_with_email_and_password(email, password)

func _on_signup_succeeded(auth):
	print("[SIGNUP] SUCCESS")
	
	#print("[SIGNUP] SENDING VERIFICATION EMAIL")
	#var sent = Firebase.Auth.send_account_verification_email()
	#if sent:
		#print ("[SIGNUP] SENT VERFICATION EMAIL")
	#else:
		#print("[SIGNUP] ERROR SENDING VERFICATION EMAIL")
		
	var email = $email_ledit.text.strip_edges()
	var username = $name_ledit.text.strip_edges()
	$register_success_label.text = "Account Created!"
	$email_success_label.text = "Your login email is: " + email
	
	$email_ledit.text = ""
	$name_ledit.text = ""
	$pass_ledit.text = ""
	
	print("[SIGNUP] updating db user data..")
	var date = Time.get_date_string_from_system()
	
	var payload = {
		"username" : username,
		"email" : email,
		"member_since" : date,
		"origin" : "signup"
	}
	
	var updated = await db_utils.push_to_db(auth, db_utils.USER_COLLECTION, auth.localid, payload)
	
	if updated:
		print("[SIGNUP] username and email succesfully updated")
		
	else:
		print("[SIGNUP] username not updated. Please update in menus")
		$username_success_label.text = "Warning: we ran into an issue creating your username. \n Please update it in user settings after logging in."
	
func _on_signup_failed(error_code, message):
	$email_ledit.text = ""
	$name_ledit.text = ""
	$pass_ledit.text = ""
	
	$register_success_label.text = "Account creation failed: " + str(message)
	print("[SIGNUP] FAILED: " + str(error_code))
	print(str(message))

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/LoggedOut.tscn")
