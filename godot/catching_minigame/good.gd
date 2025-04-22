extends Area2D

signal score_point

@export var min_speed: int = 5
@export var max_speed: int = 10

func _process(delta):
	# Get the background node
	var background = get_tree().get_root().get_node("background")
	if !background:
		# Default behavior if can't find background
		position.y += min_speed
		return
	
	# Don't move if game is over or items are frozen
	if (background.has_method("is_game_over") and 
	background.is_game_over()) or (background.has_method("are_items_frozen") 
	and background.are_items_frozen()):
		return
	
	# Move down at random speed
	position.y += randi_range(min_speed, max_speed)
	
	# Remove if off screen
	if position.y > 900:
		queue_free()

func _on_area_entered(area):
	if area.name == "Player":
		emit_signal("score_point")
		queue_free()
