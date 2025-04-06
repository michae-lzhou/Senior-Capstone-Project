extends Node2D

var good = preload("res://good.tscn")
var t = randf_range(0.3, 1)

func _ready():
	$Timer.start(t)

func _on_timer_timeout():
	var screen = get_viewport_rect().size
	var pos = Vector2(randf_range(0, screen.x), -600)
	
	good = load("res://good.tscn")
	good = good.instantiate()
	
	good.position = pos
	
	add_child(good)
