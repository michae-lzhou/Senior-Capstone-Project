extends Node2D

@export var is_good: bool = true
var spawn_time := 0.0

func _ready():
	add_to_group("clickable")
	spawn_time = Time.get_ticks_msec() / 1000.0

func get_reaction_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - spawn_time

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if is_good:
			get_tree().current_scene.on_good_clicked(global_position)
		else:
			get_tree().current_scene.on_bad_clicked(global_position)
		queue_free()
