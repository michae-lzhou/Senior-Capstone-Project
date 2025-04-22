extends Node2D

@export var scroll_speed := 500.0

@onready var bg1 := $BG1
@onready var bg2 := $BG2

var texture_width: float

func _ready():
	bg1.position.x = 0
	texture_width = bg1.texture.get_size().x
	bg2.position.x = bg1.position.x + texture_width

func _process(delta):
	var move = scroll_speed * delta

	bg1.position.x -= move
	bg2.position.x -= move

	# Recycle background that scrolls off screen
	if bg1.position.x <= -texture_width:
		bg1.position.x = bg2.position.x + texture_width
	elif bg2.position.x <= -texture_width:
		bg2.position.x = bg1.position.x + texture_width
