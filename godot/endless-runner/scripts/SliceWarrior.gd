extends Node2D

var score = 0
#var lives = 3

@onready var score_label = $HUD/ScoreLabel
@onready var spawner = $Spawner
@onready var slice_trail = $SliceTrail
@onready var floating_text_scene := preload("res://scenes/FloatingText.tscn")

var trail_points = []
const MAX_TRAIL_POINTS = 15

#const level_settings : Dictionary = {1 : [20, -5, -]}

# (level = 1)
var level_idx = 0
const NUM_SPAWNS = [20, 30, 40]

const GOOD_HIT_REWARDS = [20, 27, 30]

#const GOOD_HIT_REWARD = 20
#const GOOD_MISS_PENALTY = -5

const GOOD_MISS_PENALTIES = [-5, -5, -5]
#const GOOD_MISS_PENALTY = -5

const BAD_HIT_PENALTIES = [-15, -15, -15, -15]
#const BAD_HIT_PENALTY = -15

const BAD_MISS_REWARDS = [0, 0, 0, 5]
#const BAD_MISS_REWARD = 5
#const MULTIPLIER = [1]

const G_SCALES = [0.5, 2, 5, 10]
const v0s = [1000, 2000, 3500, 7500]

#const REACTION_REWARD_SCALE = 1.0

var expected_time = find_expected_time(v0s[level_idx], G_SCALES[level_idx])

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
	print("expected time:", expected_time)
	update_score()
	spawner.max_spawns = NUM_SPAWNS[level_idx]
	spawner.g_scale = G_SCALES[level_idx]
	spawner.v0 = v0s[level_idx]
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
	var score_change = int((abs((expected_time - reaction_time) / (expected_time)) * GOOD_HIT_REWARDS[level_idx]) + 0.5)
	score += score_change
	update_score()
	show_floating_text("+" + str(score_change), pos, Color.GREEN)
	
func on_good_missed():
	GSession.good_misses += 1
	var score_change = GOOD_MISS_PENALTIES[level_idx]
	score += score_change
	if score < 0:
		score = 0
	update_score()
	show_floating_text(str(score_change), Vector2(675, 100), Color.RED)

func on_bad_sliced(pos: Vector2):
	GSession.bad_hits += 1
	var reaction_time = GSession.bad_reaction_time[-1]
	#var score_change = int(BAD_HIT_PENALTIES[level_idx] / (reaction_time + (1/REACTION_REWARD_SCALE)))
	var score_change = BAD_HIT_PENALTIES[level_idx]
	score += score_change
	if score < 0:
		score = 0
	update_score()
	show_floating_text(str(score_change), pos, Color.RED)
	#end_game()

func on_bad_missed():
	GSession.bad_misses += 1
	var score_change = BAD_MISS_REWARDS[level_idx]
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
	GSession.GStats[2]["score"].append(score)
	GSession.GStats[2]["speed"].append(speed_avg)
	GSession.GStats[2]["pos_hit"].append(pos_hit_percent)
	GSession.GStats[2]["neg_miss"].append(neg_miss_percent)
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
