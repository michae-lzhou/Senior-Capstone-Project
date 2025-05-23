extends Node2D

var game_idx = 1

@export var good_item_scene: PackedScene
@export var bad_item_scene: PackedScene

@onready var result_label: Label = $ResultLabel
@onready var swipe_up_label: Label = $HUD/SwipeUpLabel
@onready var swipe_down_label: Label = $HUD/SwipeDownLabel
@onready var arrow_up: Sprite2D = $HUD/ArrowUp
@onready var arrow_down: Sprite2D = $HUD/ArrowDown
@onready var score_label = $HUD/ScoreLabel
@onready var floating_text_scene := preload("res://scenes/FloatingText.tscn")

# Game configuration
# keep level_idx at 0, as reducing item lifespan causes possible bugs atm
# we achieve accurate reaction speed readings regardless
var level_idx = 0
const NUM_SPAWNS = [20, 30, 40, 40, 40]
const GOOD_HIT_REWARDS = [20, 27, 30, 40, 50]
const GOOD_MISS_PENALTIES = [-15, -15, -15, -15, -15]
const BAD_HIT_PENALTIES = [-15, -15, -15, -15, -15]
const BAD_MISS_REWARDS = [20, 27, 30, 40, 50]
const LIFESPAN = [5, 4, 3, 2, 1]
const SPAWN_DELAY = 1.0  # Delay between items
const RESULT_DISPLAY_TIME = 1.0  # How long to show the checkmark/x
const score_change_label = Vector2(650, 100)

# Game state
enum GameState {INTRO, WAITING_TO_SPAWN, ITEM_ACTIVE, SHOWING_RESULT, GAME_OVER}
var current_state = GameState.INTRO

# Game variables
var score = 0
var current_item: Node2D
var dragging: bool = false
var drag_start_pos: Vector2
var spawn_count: int = 0
var good_count
var bad_count
var expected_time: float
var spawn_timer: Timer
var result_timer: Timer

func _ready():
	# Initialize game state
	good_count = NUM_SPAWNS[level_idx] / 2
	bad_count = NUM_SPAWNS[level_idx] - good_count
	expected_time = LIFESPAN[level_idx] / 2
	update_score()
	
	# Set up timers
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	result_timer = Timer.new()
	result_timer.one_shot = true
	result_timer.timeout.connect(_on_result_timer_timeout)
	add_child(result_timer)
	
	# Start the intro sequence
	play_intro()

func play_intro():
	current_state = GameState.INTRO
	
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

	# Use a callback rather than direct connection to avoid potential issues
	tween.finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)

func _on_intro_finished():
	swipe_up_label.visible = false
	swipe_down_label.visible = false
	arrow_up.visible = false
	arrow_down.visible = false
	
	# Start waiting to spawn the first item
	start_waiting_to_spawn()

func start_waiting_to_spawn():
	current_state = GameState.WAITING_TO_SPAWN
	result_label.text = ""
	spawn_timer.start(SPAWN_DELAY)

func _on_spawn_timer_timeout():
	# Check if we've reached the spawn limit
	spawn_count += 1
	if spawn_count > NUM_SPAWNS[level_idx]:
		end_game()
		return
		
	spawn_item()

func spawn_item():
	current_state = GameState.ITEM_ACTIVE
	
	# Clear any previous item
	if current_item != null and is_instance_valid(current_item) and not current_item.is_queued_for_deletion():
		current_item.queue_free()
		current_item = null
	
	# Decide whether to spawn a good or bad item
	var is_good = randf() < 0.5
	if (is_good and good_count > 0) or bad_count <= 0:
		current_item = good_item_scene.instantiate()
		good_count -= 1
	else:
		current_item = bad_item_scene.instantiate()
		bad_count -= 1
		
	# Configure the item
	current_item.lifespan = LIFESPAN[level_idx]
	current_item.connect("expired_due_to_timeout", Callable(self, "_on_item_timeout"))
	add_child(current_item)

func _unhandled_input(event: InputEvent) -> void:
	# Only process input if an item is active
	if current_state != GameState.ITEM_ACTIVE:
		return
		
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
	if current_state != GameState.ITEM_ACTIVE:
		return
		
	current_state = GameState.SHOWING_RESULT
	
	# Ensure the current item is valid
	if not is_instance_valid(current_item) or current_item.is_queued_for_deletion():
		# If current_item is invalid, go back to waiting state
		start_waiting_to_spawn()
		return
	
	var reaction_time = current_item.get_reaction_time()
	var correct = (current_item.is_good and action == "pull") or (not current_item.is_good and action == "push")

	# First animate the item exiting
	var tween = current_item.animate_exit(action)
	# Store the item's is_good value before animation finishes (item might be freed)
	var was_good = current_item.is_good
	
	# Safety check in case tween is null
	if tween:
		await tween.finished
	else:
		# Wait a short time if tween wasn't created
		await get_tree().create_timer(0.3).timeout
	
	# Then display the result
	if correct:
		on_correct_swipe(reaction_time, was_good)
		result_label.text = "✅"
	else:
		on_incorrect_swipe(reaction_time, was_good)
		result_label.text = "❌"
		
	# Start the timer for showing the result
	result_timer.start(RESULT_DISPLAY_TIME)

func _on_item_timeout(item):
	if current_state != GameState.ITEM_ACTIVE:
		return
		
	current_state = GameState.SHOWING_RESULT
	
	# Make sure the item is still valid before accessing its properties
	var is_good = false
	if is_instance_valid(item) and not item.is_queued_for_deletion():
		is_good = item.is_good
	elif is_instance_valid(current_item) and not current_item.is_queued_for_deletion():
		is_good = current_item.is_good
	
	var reaction_time = LIFESPAN[level_idx]
	on_incorrect_swipe(reaction_time, is_good)
	result_label.text = "⏰"
	
	# Start the timer for showing the result
	result_timer.start(RESULT_DISPLAY_TIME)

func _on_result_timer_timeout():
	# After showing the result, start waiting for the next spawn
	start_waiting_to_spawn()

func on_correct_swipe(reaction_time: float, is_good: bool) -> void:
	print("CORRECT CHOICE:", "GOOD" if is_good else "BAD", "Reaction Time:", reaction_time)
	
	if is_good:
		GSession.good_hits += 1
		GSession.good_reaction_time.append(reaction_time)
		var score_change = int((abs((expected_time - reaction_time) / expected_time) * GOOD_HIT_REWARDS[level_idx]) + 0.5)
		score += score_change
		update_score()
		show_floating_text("+" + str(score_change), score_change_label, Color.GREEN)
	else:
		GSession.bad_misses += 1
		var score_change = int((abs((expected_time - reaction_time) / expected_time) * BAD_MISS_REWARDS[level_idx]) + 0.5)
		score += score_change
		update_score()
		show_floating_text("+" + str(score_change), score_change_label, Color.GREEN)

func on_incorrect_swipe(reaction_time: float, is_good: bool) -> void:
	print("INCORRECT CHOICE:", "GOOD" if is_good else "BAD", "Reaction Time:", reaction_time)
	
	if is_good:
		GSession.good_misses += 1
		var score_change = int(GOOD_MISS_PENALTIES[level_idx])
		score += score_change
		if score < 0:
			score = 0
		update_score()
		show_floating_text(str(score_change), score_change_label, Color.RED)
	else:
		GSession.bad_hits += 1
		GSession.bad_reaction_time.append(reaction_time)
		var score_change = int(BAD_HIT_PENALTIES[level_idx])
		score += score_change
		if score < 0:
			score = 0
		update_score()
		show_floating_text(str(score_change), score_change_label, Color.RED)

func update_score():
	score_label.text = "Score: " + str(score)

func show_floating_text(text: String, pos: Vector2, color: Color):
	var label = floating_text_scene.instantiate()
	label.text = text
	label.position = pos
	label.modulate = color
	add_child(label)

func end_game():
	current_state = GameState.GAME_OVER
	
	GSession.session_score = score
	
	# Calculate and store stats
	var new_arr = GSession.good_reaction_time
	var speed_sum = 0.0
	
	for num in new_arr:
		speed_sum += num
	var speed_avg = speed_sum / max(new_arr.size(), 1)  # Avoid division by zero
	
	var total_good = max(GSession.good_hits + GSession.good_misses, 1)  # Avoid division by zero
	var total_bad = max(GSession.bad_hits + GSession.bad_misses, 1)     # Avoid division by zero
	
	var pos_hit_percent = float(GSession.good_hits) / total_good
	var neg_miss_percent = float(GSession.bad_misses) / total_bad
	
	GSession.good_hit_percent = pos_hit_percent
	GSession.bad_miss_percent = neg_miss_percent
	GSession.GStats[game_idx]["score"].append(score)
	GSession.GStats[game_idx]["speed"].append(speed_avg)
	GSession.GStats[game_idx]["pos_hit"].append(pos_hit_percent)
	GSession.GStats[game_idx]["neg_miss"].append(neg_miss_percent)
	GSession.print_stats()
	
	# Wait a moment before ending the game
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/EndGame.tscn")
