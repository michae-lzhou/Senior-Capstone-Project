extends "res://scripts/BaseSnappable.gd"

@export var bad_texture: Texture2D

func _ready():
	super._ready()
	is_good = false
	sprite.texture = bad_texture
