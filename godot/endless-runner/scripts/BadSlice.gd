extends RigidBody2D

func _ready():
	add_to_group("sliceable")

func on_sliced():
	get_tree().current_scene.on_bad_sliced(global_position)
	queue_free()
