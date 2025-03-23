extends Control

var config_script

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	config_script = $TabContainer/Configuration
	$TabContainer/Configuration/SalientBox/HBoxContainer/SalientLeftButton.pressed.connect(config_script._on_salient_left_pressed)
	$TabContainer/Configuration/SalientBox/HBoxContainer/SalientRightButton.pressed.connect(config_script._on_salient_right_pressed)
	$TabContainer/Configuration/ControlBox/HBoxContainer/ControlLeftButton.pressed.connect(config_script._on_control_left_pressed)
	$TabContainer/Configuration/ControlBox/HBoxContainer/ControlRightButton.pressed.connect(config_script._on_control_right_pressed)
	$BackButton.pressed.connect(_on_back_pressed)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
