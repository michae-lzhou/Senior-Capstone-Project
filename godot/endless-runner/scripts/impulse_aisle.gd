extends Node2D

@export var scroll_speed := 500.0

@onready var bg1: Sprite2D = $BG1
@onready var bg2: Sprite2D = $BG2
@onready var game_timer = $GameTimer
@onready var timer_label = $HUD/TimerLabel

var time_remaining: float = 60.0
var texture_width: float

func _ready():
	texture_width = bg1.texture.get_width() * bg1.scale.x
	bg1.position.x = 0
	bg2.position.x = texture_width
	game_timer.timeout.connect(_on_game_timer_timeout)

func _process(delta):
	# Scrolling background logic
	var move_amount = scroll_speed * delta

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

func on_good_clicked(pos: Vector2):
	print("Good item clicked! +10 points")

func on_bad_clicked(pos: Vector2):
	print("Bad item clicked! -10 points")
	
func _on_game_timer_timeout():
	print("TIME'S UP!")
	get_tree().change_scene_to_file("res://scenes/EndGame.tscn")
	
