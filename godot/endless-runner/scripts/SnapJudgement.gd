extends Node2D

@export var good_item_scene: PackedScene
@export var bad_item_scene: PackedScene

@onready var result_label: Label = $ResultLabel
@onready var swipe_up_label: Label = $HUD/SwipeUpLabel
@onready var swipe_down_label: Label = $HUD/SwipeDownLabel
@onready var arrow_up: Sprite2D = $HUD/ArrowUp
@onready var arrow_down: Sprite2D = $HUD/ArrowDown
@onready var score_label = $HUD/ScoreLabel
@onready var floating_text_scene := preload("res://scenes/FloatingText.tscn")

var score = 0

var current_item: Node2D
var dragging: bool = false
var drag_start_pos: Vector2
var spawn_count: int = 0

const score_change_label = Vector2(650, 100)

var game_idx = 1

var level_idx = 0

var good_count
var bad_count

const NUM_SPAWNS = [20, 30, 40, 40, 40]

const GOOD_HIT_REWARDS = [20, 27, 30, 40, 50]
const GOOD_MISS_PENALTIES = [-15, -15, -15, -15, -15]

const BAD_HIT_PENALTIES = [-15, -15, -15, -15, -15]
const BAD_MISS_REWARDS = [20, 27, 30, 40, 50]

const LIFESPAN = [5, 4, 3, 2, 1]
var expected_time: float = LIFESPAN[level_idx]

func _ready():
	good_count = NUM_SPAWNS[level_idx] / 2
	bad_count = NUM_SPAWNS[level_idx] - good_count
	play_intro()
	update_score()

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
	
func update_score():
	score_label.text = "Score: " + str(score)

func show_new_item() -> void:
	spawn_count += 1
	if (spawn_count > NUM_SPAWNS[level_idx]):
		await get_tree().create_timer(3.0).timeout
		end_game()
	if current_item:
		current_item.queue_free()

	var is_good = randf() < 0.5
	if (is_good and (good_count > 0)) or bad_count == 0:
		current_item = good_item_scene.instantiate()
	else:
		current_item = bad_item_scene.instantiate()
	current_item.lifespan = LIFESPAN[level_idx]
	
	current_item.connect("expired_due_to_timeout", Callable(self, "_on_item_timeout"))
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
	if is_good:
		GSession.good_hits += 1
		GSession.good_reaction_time.append(reaction_time)
		var score_change = int((abs((expected_time - reaction_time) / (expected_time)) * GOOD_HIT_REWARDS[level_idx]) + 0.5)
		#var score_change = int((reaction_time * GOOD_HIT_REWARDS[level_idx]) + 0.5)
		score += score_change
		update_score()
		show_floating_text("+" + str(score_change), score_change_label, Color.GREEN)
	if not is_good:
		GSession.bad_misses += 1
		var score_change = int((abs((expected_time - reaction_time) / (expected_time)) * BAD_MISS_REWARDS[level_idx]) + 0.5)
		#var score_change = int((reaction_time * BAD_MISS_REWARDS[level_idx]) + 0.5)
		print(score_change)
		score += score_change
		update_score()
		show_floating_text("+" + str(score_change), score_change_label, Color.GREEN)

func on_incorrect_swipe(reaction_time: float, is_good: bool) -> void:
	print("INCORRECT CHOICE:", "GOOD" if is_good else "BAD", "Reaction Time:", reaction_time)
	if is_good:
		GSession.good_misses += 1
		var score_change = int(GOOD_MISS_PENALTIES[level_idx])
		#var score_change = int((reaction_time * GOOD_MISS_PENALTIES[level_idx]) + 0.5)
		score += score_change
		if score < 0:
			score = 0
		update_score()
		show_floating_text(str(score_change), score_change_label, Color.RED)
	if not is_good:
		GSession.bad_hits += 1
		GSession.bad_reaction_time.append(reaction_time)
		var score_change = int(BAD_HIT_PENALTIES[level_idx])
		#var score_change = int((reaction_time * BAD_HIT_PENALTIES[level_idx]) + 0.5)
		score += score_change
		if score < 0:
			score = 0
		update_score()
		show_floating_text(str(score_change), score_change_label, Color.RED)
		
func _on_item_timeout(item):
	var reaction_time = LIFESPAN[level_idx]
	on_incorrect_swipe(reaction_time, item.is_good)
	result_label.text = "⏰"
	show_new_item()

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

func show_floating_text(text: String, pos: Vector2, color: Color):
	var label = floating_text_scene.instantiate()
	label.text = text
	label.position = pos
	label.modulate = color
	add_child(label)

func end_game():
	GSession.session_score = score
	#var speed = calculate_average_speed_score(GSession.good_reaction_time + GSession.bad_reaction_time)
	var new_arr = (GSession.good_reaction_time) #+ GSession.bad_reaction_time
	var speed_sum = 0.0
	
	for num in new_arr:
		speed_sum += num
	var speed_avg = speed_sum / new_arr.size()
	
	#var session_number = 0
	#if GSession.G2Score.size() != 0:
		#session_number = GSession.G2Score[-1]
	var pos_hit_percent = GSession.good_hits / (GSession.good_hits + GSession.good_misses)
	var neg_miss_percent = GSession.bad_misses / (GSession.bad_hits + GSession.bad_misses)
	
	GSession.good_hit_percent = pos_hit_percent
	GSession.bad_miss_percent = neg_miss_percent
	GSession.GStats[game_idx]["score"].append(score)
	GSession.GStats[game_idx]["speed"].append(speed_avg)
	GSession.GStats[game_idx]["pos_hit"].append(pos_hit_percent)
	GSession.GStats[game_idx]["neg_miss"].append(neg_miss_percent)
	GSession.print_stats()
	get_tree().change_scene_to_file("res://scenes/EndGame.tscn")
