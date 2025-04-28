extends Control

@onready var graph_holder = $VBoxContainer/ScoreGraphLabels/GraphHolder
var play_again_game

func _ready():
	$BackButton.pressed.connect(_on_back_pressed)
	$StatsButton.pressed.connect(_on_statistics_pressed)
	$PlayAgainButton.pressed.connect(_on_playagain_pressed)

	# Set the score label text
	$Score.text = "%d" % GSession.session_score
	
	$Accuracy.text = "Alternatives Hit:                                       %.2f%%\nTemptations Avoided:                           %.2f%%" % [GSession.good_hit_percent * 100, GSession.bad_miss_percent * 100]
	
	var game_idx : int = GSession.game
	# Load and display the appropriate graph
	_load_graph_for_game(game_idx)
	
	print("START: [GAME END] uploading session results for game", game_idx, " to cloud")
	$save_status_label.text = "Saving score to cloud.."
	
	# upload to db
	var stats_path = db_utils.USER_COLLECTION + "/" + GSession.auth_m.localid + "/" + db_utils.STATS_COLLECTION
	
	var payload = {
		"scores" = GSession.GStats[game_idx]["score"],
		"average_reaction_speeds" = GSession.GStats[game_idx]["speed"],
		"positive_hit_percents" = GSession.GStats[game_idx]["pos_hit"],
		"negative_miss_percents" = GSession.GStats[game_idx]["neg_miss"]
	}
	
	var res = await db_utils.push_to_db(GSession.auth_m, stats_path, "game" + str(game_idx), payload)
	
	if res:
		print("[GAME END] SUCCESS results uploaded to cloud")
	else:
		print("[GAME END] FAILED to upload results to cloud")
	
	print("END: [GAME END]")
	$save_status_label.text = "Saved to cloud!"
	
func _on_back_pressed():
	GSession.reset()
	get_tree().change_scene_to_file("res://scenes/GameSelection.tscn")
	
func _on_statistics_pressed():
	GSession.reset()
	get_tree().change_scene_to_file("res://scenes/Statistics.tscn")
	
func _on_playagain_pressed():
	GSession.reset()
	get_tree().change_scene_to_file(play_again_game)

func _load_graph_for_game(game_idx: int) -> void:
	var graph_path := ""  # Use := for type inference (optional)
	var score_array

	match game_idx:
		1:
			graph_path = "res://scenes/G1Score.tscn"
			score_array = GSession.GStats[1]["score"]
			play_again_game = "res://scenes/EndlessRunner.tscn"
		2:
			graph_path = "res://scenes/G2Score.tscn"
			score_array = GSession.GStats[2]["score"]
			play_again_game = "res://scenes/SliceWarrior.tscn"
		3:
			graph_path = "res://scenes/G3Score.tscn"
			score_array = GSession.GStats[3]["score"]
			#play_again_game = "res://scenes/game3.tscn"
		4:
			graph_path = "res://scenes/G4Score.tscn"
			score_array = GSession.GStats[4]["score"]
			play_again_game = "res://scenes/ImpulseAisle.tscn"
		_:
			graph_path = ""  # Optional, since it's initialized above
			score_array = []
			play_again_game = ""

	toggle_high_score_visibility(score_array)

	if graph_path != "":
		var graph_scene = load(graph_path)
		var graph_instance = graph_scene.instantiate()
		graph_holder.add_child(graph_instance)
	else:
		push_warning("No graph scene found for game: %s" % game_idx)
	
func toggle_high_score_visibility(score_array: Array) -> void:
	$High_Score.visible = false

	if score_array.size() == 0:
		return

	var last_y = score_array[-1]
	var max_y = score_array[0]
	
	for point in score_array:
		if point > max_y:
			max_y = point
	
	if last_y == max_y:
		$High_Score.visible = true
