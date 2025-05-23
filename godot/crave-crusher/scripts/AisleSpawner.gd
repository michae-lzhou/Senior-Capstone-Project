extends Node2D

@export var good_item_scene: PackedScene
@export var bad_item_scene: PackedScene

var shelf_y_positions = [530, 760, 1000, 1230]  # y-positions for spawning shelves

func _ready():
	spawn_loop()

func spawn_loop():
	while true:
		spawn_item()
		await get_tree().create_timer(1.0).timeout

func spawn_item():
	print("SPAWNING ITEM")
	var is_good = randf() < 0.5
	var item = good_item_scene.instantiate() if is_good else bad_item_scene.instantiate()
	item.position = Vector2(1200, shelf_y_positions.pick_random())
	get_tree().current_scene.add_child(item)
