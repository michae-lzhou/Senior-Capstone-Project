extends Control

@onready var graph_holder = $VBoxContainer/ScoreGraphLabels/GraphHolder
var play_again_game

func _ready():
	$BackButton.pressed.connect(_on_back_pressed)
	$StatsButton.pressed.connect(_on_statistics_pressed)
	$PlayAgainButton.pressed.connect(_on_playagain_pressed)

	# Set the score label text
	$Score.text = "%d" % GSession.session_score

	# Load and display the appropriate graph
	_load_graph_for_game(GSession.game)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/GameSelection.tscn")
	
func _on_statistics_pressed():
	get_tree().change_scene_to_file("res://scenes/Statistics.tscn")
	
func _on_playagain_pressed():
	get_tree().change_scene_to_file(play_again_game)

func _load_graph_for_game(game_name: int) -> void:
	var graph_path := ""  # Use := for type inference (optional)
	var score_array

	match game_name:
		1:
			graph_path = "res://scenes/G1Score.tscn"
			score_array = GSession.G1Score
			play_again_game = "res://scenes/EndlessRunner.tscn"
		2:
			graph_path = "res://scenes/G2Score.tscn"
			score_array = GSession.G2Score
			play_again_game = "res://scenes/SliceWarrior.tscn"
		3:
			graph_path = "res://scenes/G3Score.tscn"
			score_array = GSession.G3Score
			#play_again_game = "res://scenes/game3.tscn"
		4:
			graph_path = "res://scenes/G4Score.tscn"
			score_array = GSession.G4Score
			#play_again_game = "res://scenes/gmae4.tscn"
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
		push_warning("No graph scene found for game: %s" % game_name)
	
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
