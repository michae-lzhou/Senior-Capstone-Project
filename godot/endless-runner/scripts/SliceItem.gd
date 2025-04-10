extends RigidBody2D

var is_good = true

func on_sliced():
	if is_good:
		get_tree().current_scene.on_good_sliced()
	else:
		get_tree().current_scene.on_bad_sliced()
	queue_free()
