extends Area2D

func _process(delta: float):
	position.y += randi_range(5, 10)


func _on_area_entered(area: Area2D):
	queue_free()
