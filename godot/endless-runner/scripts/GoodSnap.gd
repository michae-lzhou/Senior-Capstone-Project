extends "res://scripts/BaseSnappable.gd"

@export var good_texture: Texture2D

func _ready():
	super._ready()
	is_good = true
	sprite.texture = good_texture
