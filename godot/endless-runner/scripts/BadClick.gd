extends "res://scripts/BaseClickable.gd"

@onready var sprite: Sprite2D = $Sprite2D
@export var bad_texture: Texture2D

func _ready():
	super._ready()
	is_good = false
	sprite.texture = bad_texture
