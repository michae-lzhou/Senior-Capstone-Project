extends Node2D

@export var good_item_texture: Texture2D
@export var bad_item_texture: Texture2D

@onready var temptation: Sprite2D = $Temptation
@onready var result_label: Label = $ResultLabel

var current_item_type: String = ""  # "good" or "bad"
var reaction_start_time: int = 0
var dragging: bool = false
var drag_start_pos: Vector2
var max_rounds: int = 10
var current_round: int = 0

func _ready() -> void:
	show_new_item()

func show_new_item() -> void:
	var is_good = randf() < 0.5

	if is_good:
		current_item_type = "good"
		temptation.texture = good_item_texture
	else:
		current_item_type = "bad"
		temptation.texture = bad_item_texture

	temptation.position = get_viewport_rect().size / 2
	temptation.visible = true
	result_label.text = ""
	reaction_start_time = Time.get_ticks_msec()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch

		if touch_event.pressed:
			dragging = true
			drag_start_pos = touch_event.position
		elif dragging:
			dragging = false
			var swipe_vector = touch_event.position - drag_start_pos

			if swipe_vector.length() > 50.0 and abs(swipe_vector.y) > abs(swipe_vector.x):
				if swipe_vector.y < 0:
					handle_judgement("push")  # swipe up
				else:
					handle_judgement("pull")  # swipe down

func handle_judgement(action: String) -> void:
	var reaction_time = float(Time.get_ticks_msec() - reaction_start_time) / 1000.0
	var correct = false

	if current_item_type == "bad" and action == "push":
		correct = true
	elif current_item_type == "good" and action == "pull":
		correct = true

	if correct:
		result_label.text = "✅ (%.2f s)" % reaction_time
	else:
		result_label.text = "❌ (%.2f s)" % reaction_time

	var end_y: float = 0.0
	if action == "push":
		end_y = -200.0
	else:
		end_y = get_viewport_rect().size.y + 200.0

	var tween := create_tween()
	tween.tween_property(temptation, "position", Vector2(temptation.position.x, end_y), 0.4)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	await tween.finished
	show_new_item()
