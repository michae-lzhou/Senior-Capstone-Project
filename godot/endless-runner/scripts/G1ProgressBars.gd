extends HBoxContainer

@onready var score_progress_bar: TextureProgressBar = $ScoreProgressBar
#var score_fill_speed: float = 100.0

@onready var speed_progress_bar: TextureProgressBar = $SpeedProgressBar
#var speed_fill_speed: float = 75.0

@onready var focus_progress_bar: TextureProgressBar = $FocusProgressBar
#var focus_fill_speed: float = 50.0

var count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	count+=1
	if score_progress_bar.value < score_progress_bar.max_value * 0.85:
		if count % 1 == 0:
			score_progress_bar.value += 1
	if speed_progress_bar.value < speed_progress_bar.max_value * 0.5:
		if count % 1 == 0:
			speed_progress_bar.value += 1
	if focus_progress_bar.value < focus_progress_bar.max_value * 0.65:
		if count % 1 == 0:
			focus_progress_bar.value += 1
