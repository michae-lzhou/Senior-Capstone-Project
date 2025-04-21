extends Area2D

@export var speed: int = 400
@export var block_duration: float = 2.0  # How long block lasts
@export var block_cooldown: float = 5.0  # Cooldown between blocks

var velocity = Vector2()
var screen_size
var can_block = true
var is_blocking = false
var block_timer = 0.0

# Define signals
signal block_started
signal block_ended

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	# Handle movement
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	
	if velocity.length() > 0:
		velocity = velocity * speed
	
	position += velocity * delta
	position.x = clamp(position.x, 30, screen_size.x - 30)
	position.y = clamp(position.y, 0, screen_size.y)
	
	# Handle block timers
	if is_blocking:
		block_timer += delta
		if block_timer >= block_duration:
			end_block()

# Try to activate block if possible
func try_activate_block():
	if can_block and !is_blocking:
		start_block()

func start_block():
	is_blocking = true
	can_block = false
	block_timer = 0.0
	
	# Visual feedback
	modulate = Color(0.2, 0.6, 1.0, 0.8)  # Blue tint
	
	# Emit signal
	emit_signal("block_started")

func end_block():
	is_blocking = false
	block_timer = 0.0
	
	# Visual feedback
	modulate = Color(1, 1, 1, 1)  # Normal color
	
	# Emit signal
	emit_signal("block_ended")
	
	# Cooldown will be handled by background script
