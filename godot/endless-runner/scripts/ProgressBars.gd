extends VBoxContainer
@export var game_idx : int = 0  # The key to use in GSession

@onready var score_progress_bar: TextureProgressBar = $"Progress Bars/ScoreProgressBar"
#var score_fill_speed: float = 100.0

@onready var speed_progress_bar: TextureProgressBar = $"Progress Bars/SpeedProgressBar"
#var speed_fill_speed: float = 75.0

#@onready var focus_progress_bar: TextureProgressBar = $"Progress Bars/FocusProgressBar"
#var focus_fill_speed: float = 50.0

var count = 0
var rank_name : String
var score_fill : float
var speed_fill : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("[STATS] SCORE RATING: ", GSession.GStats[game_idx]["score_rating"])
	#print("[STATS] SPEED RATING: ", GSession.GStats[game_idx]["avg_react_time"])
	
	var rank_idx = GSession.GStats[game_idx]["rank"]
	var rank_name = GSession.rank_names[rank_idx]
	
	$rank_label.text = "Rank: " + str(rank_name)
	
	score_fill = float(GSession.GStats[game_idx]["score_rating"]) / GSession.rank_partitions[game_idx][0]
	
	var react_time : float = GSession.GStats[game_idx]["avg_react_time"]
	if react_time == 0:
		speed_fill = 0
	else:
		speed_fill = (GSession.max_react_times[game_idx] - react_time)/GSession.max_react_times[game_idx]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	count+=1
	#if score_progress_bar.value < score_progress_bar.max_value * 0.85:
	if score_progress_bar.value < score_progress_bar.max_value * score_fill:
		#if count % 3 == 0:
		score_progress_bar.value += 1
	if speed_progress_bar.value < speed_progress_bar.max_value * speed_fill:
		#if count % 3 == 0:
		speed_progress_bar.value += 1
	#if focus_progress_bar.value < focus_progress_bar.max_value * 0.65:
		#if count % 1 == 0:
			#focus_progress_bar.value += 1
