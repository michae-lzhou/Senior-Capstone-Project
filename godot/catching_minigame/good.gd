extends Area2D

# Add a signal for scoring
signal score_point

func _process(delta: float):
	position.y += randi_range(5, 10)
	
	# If object falls off screen, remove it
	if position.y > 900:
		queue_free()

func _on_area_entered(area: Area2D):
	# If the player catches the object, emit the score signal
	if area.name == "Player":
		emit_signal("score_point")
	queue_free()
