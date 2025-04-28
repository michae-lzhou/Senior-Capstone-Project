extends Node2D

@export var item_scene: PackedScene
@export var good_texture: Texture2D
@export var bad_texture: Texture2D

var shelf_y_positions = [520, 750, 990, 1220]  # y-positions for spawning shelves

func _ready():
	spawn_loop()

func spawn_loop():
	while true:
		spawn_item()
		await get_tree().create_timer(1.0).timeout # 1.0 seconds between each spawn

func spawn_item():
	var item = item_scene.instantiate()
	item.is_good = randf() < 0.5  # 50% chance good - can change
	item.good_texture = good_texture
	item.bad_texture = bad_texture
	item.position = Vector2(1200, shelf_y_positions.pick_random())
	get_parent().add_child(item)
