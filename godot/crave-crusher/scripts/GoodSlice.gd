extends "res://scripts/BaseSliceable.gd"

var good_images: Array = []
@onready var sprite: Sprite2D = $Sprite2D
const TARGET_WIDTH = 400.0

func _ready():
	super._ready()  # call BaseItem.gd's _ready()
	is_good = true  # tag this as a good item

	if good_images.is_empty():
		if GSession.salient_idx == 1:
			load_good_images("res://assets/cigarette_alt_icons/")
		else:
			load_good_images("res://assets/alcohol_alt_icons/")

	sprite.texture = good_images[randi() % good_images.size()]
	if sprite.texture:
		var original_width = sprite.texture.get_width()
		var scale_factor = TARGET_WIDTH / original_width
		sprite.scale = Vector2(scale_factor, scale_factor)

func load_good_images(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") and not dir.current_is_dir():
				var image_path = path + file_name
				good_images.append(load(image_path))
			file_name = dir.get_next()
		dir.list_dir_end()
