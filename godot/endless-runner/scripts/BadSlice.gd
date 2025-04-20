extends RigidBody2D

var spawn_time: float

func _ready():
	add_to_group("sliceable")
	spawn_time = Time.get_ticks_msec() / 1000.0 # seconds


func on_sliced():
	var slice_time = Time.get_ticks_msec() / 1000.0
	var reaction_time = slice_time - spawn_time
	GSession.bad_reaction_time.append(reaction_time)
	get_tree().current_scene.on_bad_sliced(global_position)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	get_tree().current_scene.on_bad_missed()
	queue_free()
