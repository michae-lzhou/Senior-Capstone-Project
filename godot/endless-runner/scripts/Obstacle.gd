extends Node2D

@export var fall_speed: float = 300.0

func _process(delta):
	position.y += fall_speed * delta
	
	# Remove when off screen
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()
