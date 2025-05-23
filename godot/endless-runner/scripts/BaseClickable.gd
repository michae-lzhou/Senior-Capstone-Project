# BaseClickable.gd
extends Node2D

@export var is_good: bool = true
var spawn_time: float

func _ready():
	add_to_group("clickable")
	spawn_time = Time.get_ticks_msec() / 1000.0  # seconds

func is_good_item() -> bool:
	return is_good

func is_bad_item() -> bool:
	return !is_good

func get_reaction_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - spawn_time

func on_clicked():
	var click_time = Time.get_ticks_msec() / 1000.0
	var reaction_time = click_time - spawn_time
	
	if is_good:
		GSession.good_reaction_time.append(reaction_time)
		get_tree().current_scene.on_good_clicked(global_position)
	else:
		GSession.bad_reaction_time.append(reaction_time)
		get_tree().current_scene.on_bad_clicked(global_position)
	queue_free()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		on_clicked()

# Called when the item exits the screen (you'll need to connect this to a VisibleOnScreenNotifier2D)
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_good:
		get_tree().current_scene.on_good_missed()
	else:
		get_tree().current_scene.on_bad_missed()
	queue_free()
