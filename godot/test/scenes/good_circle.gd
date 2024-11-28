extends Area2D

var speed: float = 100
var is_dying = false

func _process(delta):
	if is_dying:
		# Shrink and fade
		scale *= 0.95  # Shrink by 5% each frame
		modulate.a *= 0.95  # Fade by 5% each frame
		if modulate.a < 0.1:  # Once nearly invisible
			queue_free()
	else:
		# Normal falling behavior
		position.y += speed * delta
		if position.y > get_viewport_rect().size.y:
			print("Good Circle missed")
			queue_free()  # Delete the circle when it falls off-screen

func _ready():
	$Sprite2D.modulate = Color.DARK_GREEN # Set color
	$CollisionShape2D.scale = Vector2(1, 1) # Set collision area
	position.y = 50
	input_pickable = true
	# If CollisionShape2D is a child of this node in the circle scene
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:# and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		is_dying = true; # Cue death animation
		print("Good Circle popped")  # Debug message
