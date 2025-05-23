# BaseSnappable.gd
extends Node2D

@export var is_good: bool = true
@export var lifespan: float = 3.0
var spawn_time := 0.0

signal expired_due_to_timeout(item)

func _ready():
	spawn_time = Time.get_ticks_msec() / 1000.0
	position = get_viewport_rect().size / 2
	visible = true
	await get_tree().create_timer(lifespan).timeout
	_on_lifespan_expired()

func get_reaction_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - spawn_time

func animate_exit(direction: String) -> Tween:
	var end_y: float = -500.0 if (direction == "push") else get_viewport_rect().size.y + 500.0
	var tween := create_tween()
	tween.tween_property(self, "position", Vector2(position.x, end_y), 0.4)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	return tween
	
func _on_lifespan_expired():
	if is_instance_valid(self):
		emit_signal("expired_due_to_timeout", self)
		queue_free()
