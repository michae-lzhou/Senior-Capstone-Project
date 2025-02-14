extends CharacterBody2D

@export var move_speed: float = 300.0
const LANE_CHANGE_SPEED = 300.0
var lanes = []
var current_lane = 1
var touch_start_x = 0

func _ready():
	add_to_group("player")
	
	collision_layer = 1
	collision_mask = 2
	
	lanes = [
		get_parent().get_node("Lane1").position,
		get_parent().get_node("Lane2").position,
		get_parent().get_node("Lane3").position
	]
	position = Vector2(lanes[current_lane].x, 900)

# Handle keyboard input
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_LEFT:
			move("left")
		elif event.keycode == KEY_RIGHT:
			move("right")
	
	# Handle touch input
	elif event is InputEventScreenTouch:
		if event.pressed:
			# Store the starting x position of the touch
			touch_start_x = event.position.x
		else:
			# Calculate swipe distance
			var swipe_distance = event.position.x - touch_start_x
			if abs(swipe_distance) > 50:  # Minimum swipe distance
				move("left" if swipe_distance < 0 else "right")
	
	# Handle simple taps on screen sides
	elif event is InputEventScreenTouch and event.pressed:
		var screen_width = get_viewport_rect().size.x
		if event.position.x < screen_width / 2:
			move("left")
		else:
			move("right")

func move(direction):
	var new_lane = current_lane
	if direction == "left":
		new_lane = max(0, current_lane - 1)
	elif direction == "right":
		new_lane = min(len(lanes) - 1, current_lane + 1)
	
	if new_lane != current_lane:
		current_lane = new_lane
		var tween = create_tween()
		tween.tween_property(self, "position:x", lanes[current_lane].x, 0.2)

func hit_bad_object():
	var original_position = position
	modulate = Color(1, 0, 0)
	
	var shake_amount = 5.0
	for i in range(5):
		position += Vector2(randf_range(-shake_amount, shake_amount), 
				randf_range(-shake_amount, shake_amount))
		await get_tree().create_timer(0.05).timeout
	
	position = original_position
	modulate = Color(1, 1, 1)

func hit_good_object():
	modulate = Color(0, 1, 0)
	scale = Vector2(1.2, 1.2)
	
	await get_tree().create_timer(0.2).timeout
	
	modulate = Color(1, 1, 1)
	scale = Vector2(1, 1)
