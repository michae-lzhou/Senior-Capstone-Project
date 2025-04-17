extends Control

@onready var graph_holder = $VBoxContainer/ScoreGraphLabels/GraphHolder

func _ready():
	$BackButton.pressed.connect(_on_back_pressed)
	$StatsButton.pressed.connect(_on_statistics_pressed)

	# Set the score label text
	$Score.text = "%d" % GSession.session_score

	# Load and display the appropriate graph
	_load_graph_for_game(GSession.game)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/GameSelection.tscn")
	
func _on_statistics_pressed():
	get_tree().change_scene_to_file("res://scenes/Statistics.tscn")

func _load_graph_for_game(game_name: int) -> void:
	var graph_path := ""  # Use := for type inference (optional)

	match game_name:
		1:
			graph_path = "res://scenes/G1Score.tscn"
		2:
			graph_path = "res://scenes/G2Score.tscn"
		3:
			graph_path = "res://scenes/G3Score.tscn"
		4:
			graph_path = "res://scenes/G4Score.tscn"
		_:
			graph_path = ""  # Optional, since it's initialized above

	if graph_path != "":
		var graph_scene = load(graph_path)
		var graph_instance = graph_scene.instantiate()
		graph_holder.add_child(graph_instance)
	else:
		push_warning("No graph scene found for game: %s" % game_name)
