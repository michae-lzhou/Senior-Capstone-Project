extends Control

@onready var timer_label = $TimerLabel
@onready var score_label = $ScoreLabel
@onready var progress_bar = $ProgressBar  # If using a progress bar

var time_left = 60  # Start with 60 seconds
var score = 0

func _ready():
	update_ui()

func update_ui():
	if timer_label:
		timer_label.text = "Time Left: " + str(time_left) + "s"
	if score_label:
		score_label.text = "Score: " + str(score)
	if progress_bar:
		progress_bar.value = time_left

func update_timer(delta):
	time_left -= delta
	if time_left < 0:
		time_left = 0
	update_ui()

func update_score(new_score):
	score = new_score
	update_ui()
