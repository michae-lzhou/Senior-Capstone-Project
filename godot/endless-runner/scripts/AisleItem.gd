extends Area2D

@export var is_good: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@export var good_texture: Texture2D
@export var bad_texture: Texture2D

func _ready():
	sprite.texture = good_texture if is_good else bad_texture
	add_to_group("clickable")

func _on_item_input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton and event.pressed:
		if is_good:
			get_tree().current_scene.on_good_clicked(global_position)
		else:
			get_tree().current_scene.on_bad_clicked(global_position)
		queue_free()
