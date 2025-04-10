extends Node

@export var good_scene: PackedScene
@export var bad_scene: PackedScene
@export var spawn_interval = 1.0

func start():
	spawn_loop()

func spawn_loop():
	await get_tree().create_timer(spawn_interval).timeout

	var is_good = randf() < 0.6
	var scene = good_scene if is_good else bad_scene
	var item = scene.instantiate()

	# Start at bottom, throw upward with random arc
	item.position = Vector2(randi_range(100, 700), 600)
	item.linear_velocity = Vector2(randf_range(-150, 150), -randf_range(400, 600))

	get_parent().add_child(item)
	spawn_loop()
