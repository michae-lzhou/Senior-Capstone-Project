extends VBoxContainer

var salient_images = [preload("res://assets/alcohol_icons/beer bottle.png"), preload("res://assets/cigarette_icons/pack of cigarettes.png")]
var control_images = [preload("res://assets/fruit1/T_fruit_01.png"), preload("res://assets/fruit1/T_fruit_02.png"), preload("res://assets/fruit1/T_fruit_03.png")]

var salient_index = 0
var control_index = 0

@onready var salient_texture = $SalientBox/HBoxContainer/SalientImage
@onready var control_texture = $ControlBox/HBoxContainer/ControlImage

func _ready():
	update_images()

func update_images():
	salient_texture.texture = salient_images[salient_index]
	control_texture.texture = control_images[control_index]

func _on_salient_left_pressed():
	salient_index = abs((salient_index - 1) % salient_images.size())
	GSession.salient_idx = salient_index
	update_images()

func _on_salient_right_pressed():
	salient_index = (salient_index + 1) % salient_images.size()
	GSession.salient_idx = salient_index
	update_images()

func _on_control_left_pressed():
	control_index = (control_index - 1) % control_images.size()
	update_images()

func _on_control_right_pressed():
	control_index = (control_index + 1) % control_images.size()
	update_images()
