extends "res://scripts/BaseClickable.gd"

@onready var sprite: Sprite2D = $Sprite2D
@export var good_texture: Texture2D

func _ready():
	super._ready()
	is_good = true
	sprite.texture = good_texture
