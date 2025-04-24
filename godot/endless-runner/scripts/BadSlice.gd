extends RigidBody2D

var spawn_time: float
var bad_images: Array = []
@onready var sprite: Sprite2D = $Sprite2D
const TARGET_WIDTH = 200.0

func _ready():
	add_to_group("sliceable")
	spawn_time = Time.get_ticks_msec() / 1000.0 # seconds
	
	if bad_images.is_empty():
		if GSession.salient_idx == 1:
			load_bad_images("res://assets/cigarette_icons/")
		else:
			load_bad_images("res://assets/alcohol_icons/")

	sprite.texture = bad_images[randi() % bad_images.size()]
	if sprite.texture:
		var original_width = sprite.texture.get_width()
		var scale_factor = TARGET_WIDTH / original_width
		sprite.scale = Vector2(scale_factor, scale_factor)
	
func load_bad_images(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") and not dir.current_is_dir():
				var image_path = path + file_name
				bad_images.append(load(image_path))
			file_name = dir.get_next()
		dir.list_dir_end()

func on_sliced():
	var slice_time = Time.get_ticks_msec() / 1000.0
	var reaction_time = slice_time - spawn_time
	GSession.bad_reaction_time.append(reaction_time)
	get_tree().current_scene.on_bad_sliced(global_position)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	get_tree().current_scene.on_bad_missed()
	queue_free()
