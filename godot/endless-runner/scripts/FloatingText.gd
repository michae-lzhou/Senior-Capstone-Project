extends Label

@export var move_speed := Vector2(0, -60)
@export var lifetime := 1.0

func _ready():
	modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + move_speed, lifetime)
	tween.tween_property(self, "modulate:a", 0.0, lifetime)
	tween.tween_callback(self.queue_free)
