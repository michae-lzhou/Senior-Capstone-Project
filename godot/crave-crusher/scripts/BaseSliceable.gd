# BaseSliceable.gd
extends RigidBody2D

@export var is_good: bool = true
var spawn_time: float

func _ready():
	add_to_group("sliceable")
	spawn_time = Time.get_ticks_msec() / 1000.0  # seconds

func on_sliced():
	var slice_time = Time.get_ticks_msec() / 1000.0
	var reaction_time = slice_time - spawn_time

	if is_good:
		GSession.good_reaction_time.append(reaction_time)
		get_tree().current_scene.on_good_sliced(global_position)
	else:
		GSession.bad_reaction_time.append(reaction_time)
		get_tree().current_scene.on_bad_sliced(global_position)

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_good:
		get_tree().current_scene.on_good_missed()
	else:
		get_tree().current_scene.on_bad_missed()

	queue_free()
