extends Area2D

var speed: float = 100

func _process(delta):
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y:
		print("Bad Circle missed")
		queue_free()  # Delete the circle when it falls off-screen

func _ready():
	input_pickable = true
	# If CollisionShape2D is a child of this node in the circle scene
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:# and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		print("Bad Circle popped")  # Debug message
		queue_free()  # Remove the circle from the scene
