extends Node2D

@export var scroll_speed := 500.0

@onready var bg1 := $BG1
@onready var bg2 := $BG2

var texture_height: float

func _ready():
	bg1.position.y = 0
	texture_height = bg1.texture.get_size().y
	bg2.position.y = bg1.position.y - texture_height  # stack bg2 above bg1

func _process(delta):
	var move = scroll_speed * delta

	bg1.position.y += move
	bg2.position.y += move

	# Only reset if one has *fully* passed the screen (no >=, just >)
	if bg1.position.y > texture_height:
		print("Resetting bg1. Current:", bg1.position.y)
		bg1.position.y = bg2.position.y - texture_height
	elif bg2.position.y > texture_height:
		print("Resetting bg2. Current:", bg2.position.y)
		bg2.position.y = bg1.position.y - texture_height
