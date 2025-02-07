extends Node2D

# preload good and bad circle functionality from their scene files
var circle_scene_1 = preload("res://scenes/bad_circle.tscn")
var circle_scene_2 = preload("res://scenes/good_circle.tscn")

func _ready():
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _on_timer_timeout():
	spawn_circle()
	var random_interval = randf_range(1.0, 3.0)  # Adjust range as needed
	$Timer.start(random_interval)
	
	# Randomize spawn position at bottom of screen
func spawn_circle():
	# Randomly choose which type of circle to spawn
	var circle
	if randi() % 2 == 0:
		circle = circle_scene_1.instantiate()  # Bad Circle
	else:
		circle = circle_scene_2.instantiate()  # Good Circle
	
	add_child(circle)

	# Get screen size
	var screen_width = get_viewport_rect().size.x
	var screen_height = get_viewport_rect().size.y

	# Randomize spawn position at bottom of screen
	var spawn_x = randi() % int(screen_width)
	circle.position = Vector2(spawn_x, screen_height + 20)  # Spawn slightly below the screen

	# Apply an initial velocity
	var initial_speed = randf_range(800, 1000)  # Random upward force

	# Calculate max allowed horizontal movement based on position
	var center_x = screen_width / 2
	var distance_from_center = abs(spawn_x - center_x)  # How far from the center?

	# Limit horizontal velocity so circles don't fly off screen
	var max_horizontal_force = remap(distance_from_center, 0, center_x, 200, 300)  # Less force near edges

	# Determine direction: left side goes right, right side goes left
	var horizontal_force = randf_range(50, max_horizontal_force)
	if spawn_x < center_x:
		horizontal_force = abs(horizontal_force)  # Push right
	else:
		horizontal_force = -abs(horizontal_force)  # Push left
	
	# Pass velocity to circle
	circle.init_velocity(Vector2(horizontal_force, -initial_speed))
