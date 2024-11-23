extends Node2D

var circle_scene_1 = preload("res://scenes/bad_circle.tscn")
var circle_scene_2 = preload("res://scenes/good_circle.tscn")

func _ready():
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _on_timer_timeout():
	spawn_circle()

func spawn_circle():
	var bad_circle = circle_scene_1.instantiate()
	var good_circle = circle_scene_2.instantiate()
	add_child(bad_circle)
	add_child(good_circle)

	# Randomize the spawn position
	var screen_width = get_viewport_rect().size.x
	bad_circle.position = Vector2(randi() % int(screen_width), -10)  # Start slightly above the screen
	good_circle.position = Vector2(randi() % int(screen_width), -10)  # Start slightly above the screen
