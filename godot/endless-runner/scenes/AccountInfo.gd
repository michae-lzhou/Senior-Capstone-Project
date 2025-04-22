extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$"Name Field/user_name".text = GSession.username
	var email = GSession.email
	if email.length() > 17:
		email = email.substr(0, 17) + ".."
	$"Region Field/user_email".text = email
	$"Member Since Field/user_since".text = GSession.member_since
	
	$logout_button.pressed.connect(_on_logout_button_pressed)
	
func _on_logout_button_pressed():
	Firebase.Auth.logout()
	get_tree().change_scene_to_file("res://scenes/LoggedOut.tscn")
	
