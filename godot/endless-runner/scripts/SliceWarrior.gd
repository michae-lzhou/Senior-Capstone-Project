extends Node2D

var game_idx = 2
var score = 0
#var lives = 3

@onready var score_label = $HUD/ScoreLabel
@onready var spawner = $Spawner
@onready var slice_trail = $SliceTrail
@onready var floating_text_scene := preload("res://scenes/FloatingText.tscn")

var trail_points = []
const MAX_TRAIL_POINTS = 15

# used to scale difficulty
var rank_idx : int

# expected time item is in the air, used to award points proportional on reaction speed
var expected_time : float

# configs for each rank: array idx corresponds to rank
const NUM_SPAWNS = [20, 30, 40, 40, 40]

# good hit reward = (4 * next rank score) / num_spwans
# this ensures a player may rank up given they hit every positive item at its peak on average, and miss every salient
const GOOD_HIT_REWARDS = [20, 27, 30, 40, 50]

# good miss, bad hit/miss tweaked per level based on intended difficulty
const GOOD_MISS_PENALTIES = [-5, -5, -5, -5, -5]
const BAD_HIT_PENALTIES = [-15, -15, -20, -30, -30]
const BAD_MISS_REWARDS = [1, 2, 3, 3, 3]

# configures level difficulty - higher gravity affords less air time
const G_SCALES = [0.5, 3, 5, 10, 15]
const v0s = [1250, 2750, 3500, 5000, 6500]


var sliceable_count = 0  # Track the number of sliceable objects

func _input(event):
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		# Add trail point
		trail_points.append(event.position)
		if trail_points.size() > MAX_TRAIL_POINTS:
			trail_points.pop_front()
		slice_trail.points = trail_points

		# Slice detection
		var space = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = event.position
		#query.collision_mask = 1 << 1  # Only detects objects on layer 2

		var result = space.intersect_point(query)

		if result.size() > 0:
			var collider = result[0].collider
			if collider and collider.is_in_group("sliceable") and collider.has_method("on_sliced"):
				collider.on_sliced()

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		# Clear trail when mouse released
		trail_points.clear()
		slice_trail.points = []

func _ready():
	# if they are at the highest rank (eg 500+ rating), there is no level so floor to previous rank
	rank_idx = min(GSession.GStats[game_idx]["rank"], GSession.rank_partitions[game_idx][1] - 1)
	
	# slight buffer for expected time	
	expected_time = find_expected_time(v0s[rank_idx], G_SCALES[rank_idx]) + 0.5
	print("expected time: ", expected_time)
	
	print("Start: [SLICE WARRIOR]")
	print("[SLICE WARRIOR] playing at difficulty: ", rank_idx)
	update_score()
	spawner.max_spawns = NUM_SPAWNS[rank_idx]
	spawner.g_scale = G_SCALES[rank_idx]
	spawner.v0 = v0s[rank_idx]
	spawner.start()
	spawner.connect("spawn_limit_reached", Callable(self, "on_spawn_limit_reached"))
	# Count initial sliceable objects
	count_sliceable_objects()

func update_score():
	score_label.text = "Score: " + str(score)

func on_good_sliced(pos: Vector2):
	GSession.good_hits += 1
	var reaction_time = GSession.good_reaction_time[-1]
	#var score_change = int(GOOD_HIT_REWARDS[level_idx] / (reaction_time + (1/REACTION_REWARD_SCALE)))
#	scaled based on reaction time
	var score_change = int((abs((expected_time - reaction_time) / (expected_time)) * GOOD_HIT_REWARDS[rank_idx]) + 0.5)
	score += score_change
	update_score()
	show_floating_text("+" + str(score_change), pos, Color.GREEN)
	
func on_good_missed():
	GSession.good_misses += 1
	var score_change = GOOD_MISS_PENALTIES[rank_idx]
	score += score_change
	if score < 0:
		score = 0
	update_score()
	show_floating_text(str(score_change), Vector2(675, 100), Color.RED)

func on_bad_sliced(pos: Vector2):
	GSession.bad_hits += 1
	var reaction_time = GSession.bad_reaction_time[-1]
	#var score_change = int(BAD_HIT_PENALTIES[level_idx] / (reaction_time + (1/REACTION_REWARD_SCALE)))
	var score_change = BAD_HIT_PENALTIES[rank_idx]
	score += score_change
	if score < 0:
		score = 0
	update_score()
	show_floating_text(str(score_change), pos, Color.RED)
	#end_game()

func on_bad_missed():
	GSession.bad_misses += 1
	var score_change = BAD_MISS_REWARDS[rank_idx]
	score += score_change
	update_score()
	show_floating_text("+" + str(score_change), Vector2(675, 100), Color.GREEN)

func show_floating_text(text: String, pos: Vector2, color: Color):
	var label = floating_text_scene.instantiate()
	label.text = text
	label.position = pos
	label.modulate = color
	add_child(label)

func on_sliced():
	get_tree().current_scene.on_good_sliced(global_position)  # or on_bad_sliced
	queue_free()

# Called when spawn limit is reached
func on_spawn_limit_reached():
	# Check if there are any sliceable objects left
	count_sliceable_objects()
	
	# If there are sliceable objects left, recursively call this function
	if sliceable_count > 0:
		# Wait for a short period and check again
		await get_tree().create_timer(3.0).timeout
		on_spawn_limit_reached()
	else:
		# No sliceable objects left, end the game
		end_game()

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

# Count the number of sliceable objects in the scene
func count_sliceable_objects():
	sliceable_count = 0
	# Go through all children and check for "sliceable" objects
	for child in get_children():
		if child.is_in_group("sliceable"):
			sliceable_count += 1
			
static func find_expected_time(v0, g_scale):
	return (2 * v0) / (ProjectSettings.get_setting("physics/2d/default_gravity") * g_scale) 
