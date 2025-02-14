extends Area2D

var velocity = Vector2.ZERO
var gravity_force = 800  # Adjust gravity strength
var is_dying = false

func _process(delta):
	if is_dying:
		scale *= 0.95
		modulate.a *= 0.95
		if modulate.a < 0.1:
			queue_free()
	else:
		# Apply gravity
		velocity.y += gravity_force * delta
		position += velocity * delta  # Move circle with physics

		# Remove circle if it falls off the screen
		if position.y > get_viewport_rect().size.y + 50:
			print("Bad circle missed")
			queue_free()

func init_velocity(start_velocity: Vector2):
	velocity = start_velocity  # Set initial velocity

func _ready():
	$CollisionShape2D.scale = Vector2(1, 1)
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		is_dying = true
		print("Bad circle popped")
