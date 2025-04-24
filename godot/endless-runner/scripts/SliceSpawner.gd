extends Node

@export var good_scene: PackedScene
@export var bad_scene: PackedScene

signal spawn_limit_reached

var SPAWN_TIME_MIN = 0.5
var SPAWN_TIME_MAX = 2.0

var spawn_count = 0
const MAX_SPAWNS = 10
var good_count = MAX_SPAWNS / 2
var bad_count = MAX_SPAWNS - good_count

func start():
	spawn_count = 0
	spawn_loop()
	
func spawn_loop():
	if spawn_count >= MAX_SPAWNS:
		emit_signal("spawn_limit_reached")
		return

	var interval = randf_range(SPAWN_TIME_MIN, SPAWN_TIME_MAX)
	await get_tree().create_timer(interval).timeout

	var is_good = randf() < 0.5
	var scene
	if (is_good and (good_count > 0)) or bad_count == 0:
		scene = good_scene
		good_count -= 1
	else:
		scene = bad_scene
		bad_count -= 1
	var item = scene.instantiate()

	# Get screen dimensions
	var screen_size = get_viewport().get_visible_rect().size

	# Spawn near bottom of screen with a bit of horizontal randomness
	var spawn_x = randi_range(100, int(screen_size.x) - 100)
	item.position = Vector2(spawn_x, screen_size.y + 50)

	# Determine direction based on spawn position
	var vx: float
	if spawn_x < screen_size.x / 2:
		# If on the left half of the screen, only allow rightward movement
		vx = randf_range(250, 450)  # Positive X velocity
	else:
		# If on the right half of the screen, only allow leftward movement
		vx = randf_range(-450, -250)  # Negative X velocity

	# Launch upward toward the top/mid screen with a slight arc
	var vy = -randf_range(1200, 1700)
	item.linear_velocity = Vector2(vx, vy)

	get_parent().add_child(item)
	spawn_count += 1

	spawn_loop()
