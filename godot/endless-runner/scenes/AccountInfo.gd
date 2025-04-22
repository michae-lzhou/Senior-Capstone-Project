extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
		#$"TabContainer/Account Info/Name Field/username_label".text = SessionProperties.username

	$"Name Field/user_name".text = SessionProperties.username
	var email = SessionProperties.email
	if email.length() > 17:
		email = email.substr(0, 17) + ".."
	$"Region Field/user_email".text = email
	$"Member Since Field/user_since".text = SessionProperties.member_since
	
	$logout_button.pressed.connect(_on_logout_button_pressed)

func _on_logout_button_pressed():
	Firebase.Auth.logout()
	get_tree().change_scene_to_file("res://scenes/LoggedOut.tscn")
