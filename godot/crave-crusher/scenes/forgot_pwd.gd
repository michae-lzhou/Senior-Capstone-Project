extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubmitButton.pressed.connect(_on_submit_button_pressed)
	$BackButton.pressed.connect(_on_back_button_pressed)

func _on_submit_button_pressed() -> void:
	var email = $email_ledit.text.strip_edges()
	Firebase.Auth.send_password_reset_email(email)
	$status_label.text = "Email sent to: " + email


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/LoggedOut.tscn")
