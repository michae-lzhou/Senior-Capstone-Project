extends Node2D

#@export var scroll_speed := 540.0
@onready var bg1: Sprite2D = $BG1
@onready var bg2: Sprite2D = $BG2
@onready var game_timer = $GameTimer 
@onready var time_remaining = $GameTimer.wait_time 
@onready var timer_label = $HUD/TimerLabel
@onready var score_label = $HUD/ScoreLabel  # Add this to your scene
@onready var floating_text_scene := preload("res://scenes/FloatingText.tscn")

var game_idx = 3
var score = 0
var texture_width: float

# used to scale difficulty
var rank_idx : int
var expected_time : float

var scroll_speed = 540
# configs for each rank: array idx corresponds to rank
const GOOD_HIT_REWARDS = [14, 27, 40, 54, 67]
const GOOD_MISS_PENALTIES = [-5, -7, -10, -12, -15]
const BAD_HIT_PENALTIES = [-15, -15, -20, -30, -30]
const BAD_MISS_REWARDS = [0, 0, 0, 5, 5] 
const SCROLL_SPEEDS = [550, 650, 750, 850, 950]

func _ready():
	# Initialize rank based on player's current rating
	rank_idx = min(GSession.GStats[game_idx]["rank"], GSession.rank_partitions[game_idx][1] - 1)
	expected_time = find_expected_time(SCROLL_SPEEDS[rank_idx])

	print("Start: [IMPULSE AISLE]")
	print("[IMPULSE AISLE] playing at difficulty: ", rank_idx)
	
	# Initialize UI
	update_score()
	
	# Set up background scrolling
	texture_width = bg1.texture.get_width() * bg1.scale.x
	bg1.position.x = 0
	bg2.position.x = texture_width
	
	# Connect timer
	game_timer.timeout.connect(_on_game_timer_timeout)

func _process(delta):
	# Scrolling background logic
	var move_amount = SCROLL_SPEEDS[rank_idx] * delta
	bg1.position.x -= move_amount
	bg2.position.x -= move_amount
	
	if bg1.position.x <= -texture_width:
		bg1.position.x = bg2.position.x + texture_width
	elif bg2.position.x <= -texture_width:
		bg2.position.x = bg1.position.x + texture_width
	
	# Move all clickable items
	for child in get_children():
		if child.is_in_group("clickable"):
			child.position.x -= move_amount
			if child.position.x < -800:
				# Check if this was a good item that was missed
				if child.has_method("is_good_item") and child.is_good_item():
					on_good_missed()
				elif child.has_method("is_bad_item") and child.is_bad_item():
					on_bad_missed()
				child.queue_free()
	
	# Timer countdown
	if time_remaining > 0:
		time_remaining -= delta
		timer_label.text = str(int(time_remaining))
		# Flash red if time is under 10 seconds
		if time_remaining <= 10:
			timer_label.modulate = Color(1, 0, 0)
		else:
			timer_label.modulate = Color(1, 1, 1) 
	else:
		time_remaining = 0
		timer_label.text = "0"

func update_score():
	score_label.text = "Score: " + str(score)

func on_good_clicked(pos: Vector2):
	GSession.good_hits += 1
	
	# Calculate reaction time (you'll need to implement timing logic)
	var reaction_time = GSession.good_reaction_time[-1]  # Implement this based on when item appeared
	GSession.good_reaction_time.append(reaction_time)
	
	var score_change = int((abs((expected_time - reaction_time) / (expected_time)) * GOOD_HIT_REWARDS[rank_idx]) + 0.5)

	score += score_change
	update_score()
	show_floating_text("+" + str(score_change), pos, Color.GREEN)
	print("Good item clicked! +" + str(score_change) + " points")

func on_bad_clicked(pos: Vector2):
	GSession.bad_hits += 1
	
	# Calculate reaction time
	var reaction_time = GSession.bad_reaction_time[-1]  # Implement this based on when item appeared
	GSession.bad_reaction_time.append(reaction_time)
	
	var score_change = BAD_HIT_PENALTIES[rank_idx]
	score += score_change
	if score < 0:
		score = 0
	update_score()
	show_floating_text(str(score_change), pos, Color.RED)
	print("Bad item clicked! " + str(score_change) + " points")

func on_good_missed():
	GSession.good_misses += 1
	var score_change = GOOD_MISS_PENALTIES[rank_idx]
	score += score_change
	if score < 0:
		score = 0
	update_score()
	show_floating_text(str(score_change), Vector2(675, 100), Color.RED)

func on_bad_missed():
	GSession.bad_misses += 1
	var score_change = BAD_MISS_REWARDS[rank_idx]
	score += score_change
	update_score()
	if score_change > 0:
		show_floating_text("+" + str(score_change), Vector2(675, 100), Color.GREEN)

func show_floating_text(text: String, pos: Vector2, color: Color):
	var label = floating_text_scene.instantiate()
	label.text = text
	label.position = pos
	label.modulate = color
	add_child(label)

func _on_game_timer_timeout():
	print("TIME'S UP!")
	end_game()

func end_game():
	GSession.session_score = score
	
	# Calculate average reaction time
	var all_reaction_times = GSession.good_reaction_time + GSession.bad_reaction_time
	var speed_avg = 0.0
	if all_reaction_times.size() > 0:
		var speed_sum = 0.0
		for reaction_time in all_reaction_times:
			speed_sum += reaction_time
		speed_avg = speed_sum / all_reaction_times.size()
	
	# Calculate percentages
	var total_good = GSession.good_hits + GSession.good_misses
	var total_bad = GSession.bad_hits + GSession.bad_misses
	
	var pos_hit_percent = 0.0
	var neg_miss_percent = 0.0
	
	if total_good > 0:
		pos_hit_percent = float(GSession.good_hits) / float(total_good)
	if total_bad > 0:
		neg_miss_percent = float(GSession.bad_misses) / float(total_bad)
	
	# Store session statistics
	GSession.good_hit_percent = pos_hit_percent
	GSession.bad_miss_percent = neg_miss_percent
	
	# Update global statistics
	GSession.GStats[game_idx]["score"].append(score)
	GSession.GStats[game_idx]["speed"].append(speed_avg)
	GSession.GStats[game_idx]["pos_hit"].append(pos_hit_percent)
	GSession.GStats[game_idx]["neg_miss"].append(neg_miss_percent)
	
	# Print statistics for debugging
	GSession.print_stats()
	
	# Transition to end game scene
	get_tree().change_scene_to_file("res://scenes/EndGame.tscn")

static func find_expected_time(scroll_speed):
	return 1080.0 / scroll_speed
