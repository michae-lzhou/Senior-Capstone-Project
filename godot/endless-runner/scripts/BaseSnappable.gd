# BaseSnappable.gd
extends Node2D

@export var is_good: bool = true
@onready var sprite: Sprite2D = $Sprite2D
var spawn_time := 0.0

func _ready():
	spawn_time = Time.get_ticks_msec() / 1000.0
	position = get_viewport_rect().size / 2
	visible = true

func get_reaction_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - spawn_time

func animate_exit(direction: String) -> Tween:
	var end_y: float = -200.0 if (direction == "push") else get_viewport_rect().size.y + 200.0
	var tween := create_tween()
	tween.tween_property(self, "position", Vector2(position.x, end_y), 0.4)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	return tween
