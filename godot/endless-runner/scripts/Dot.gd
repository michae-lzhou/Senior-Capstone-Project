# Dot.gd
extends Node2D

@export var radius: float = 4.0
@export var color: Color = Color.WHITE

func _draw():
	draw_circle(Vector2.ZERO, radius, color)
