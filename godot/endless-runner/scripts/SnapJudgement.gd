extends Node2D

@export var good_item_scene: PackedScene
@export var bad_item_scene: PackedScene

@onready var result_label: Label = $ResultLabel
@onready var swipe_up_label: Label = $HUD/SwipeUpLabel
@onready var swipe_down_label: Label = $HUD/SwipeDownLabel
@onready var arrow_up: Sprite2D = $HUD/ArrowUp
@onready var arrow_down: Sprite2D = $HUD/ArrowDown

var current_item: Node2D
var dragging: bool = false
var drag_start_pos: Vector2
var max_rounds: int = 10
var current_round: int = 0

func _ready():
	play_intro()

func play_intro():
	# Intro showing arrows
	var tween = create_tween()
	swipe_up_label.modulate.a = 0.0
	swipe_down_label.modulate.a = 0.0
	arrow_up.modulate.a = 0.0
	arrow_down.modulate.a = 0.0

	tween.tween_property(swipe_up_label, "modulate:a", 1.0, 0.6)
	tween.parallel().tween_property(arrow_up, "modulate:a", 1.0, 0.6)
	tween.parallel().tween_property(swipe_down_label, "modulate:a", 1.0, 0.6)
	tween.parallel().tween_property(arrow_down, "modulate:a", 1.0, 0.6)

	tween.tween_interval(5.0)
	tween.tween_property(swipe_up_label, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(arrow_up, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(swipe_down_label, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(arrow_down, "modulate:a", 0.0, 0.5)

	tween.connect("finished", Callable(self, "_on_intro_finished"))

func _on_intro_finished():
	swipe_up_label.visible = false
	swipe_down_label.visible = false
	arrow_up.visible = false
	arrow_down.visible = false
	show_new_item()

func show_new_item() -> void:
	if current_item:
		current_item.queue_free()

	var is_good = randf() < 0.5
	current_item = good_item_scene.instantiate() if is_good else bad_item_scene.instantiate()
	add_child(current_item)
	result_label.text = ""

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

func on_correct_swipe(reaction_time: float, is_good: bool) -> void:
	print("CORRECT CHOICE:", "GOOD" if is_good else "BAD", "Reaction Time:", reaction_time)
	# Add score, increment counters, GSession.good_hits, etc.

func on_incorrect_swipe(reaction_time: float, is_good: bool) -> void:
	print("INCORRECT CHOICE:", "GOOD" if is_good else "BAD", "Reaction Time:", reaction_time)
	# Decrement score, penalty, track GSession.bad_hits, etc.

func handle_judgement(action: String) -> void:
	var reaction_time = current_item.get_reaction_time()
	var correct = (current_item.is_good and action == "pull") or (not current_item.is_good and action == "push")

	if correct:
		on_correct_swipe(reaction_time, current_item.is_good)
		result_label.text = "✅"
	else:
		on_incorrect_swipe(reaction_time, current_item.is_good)
		result_label.text = "❌"

	var tween = current_item.animate_exit(action)
	await tween.finished
	show_new_item()
