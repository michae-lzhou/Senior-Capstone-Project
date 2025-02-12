extends Node2D

var spawner_position = null

var tile = preload("res://tiles.tscn")

func _ready():
	randomize()
	spawner_position = $Spawner.get_children()
	
func spawn_tile():
	var index = randi() % spawner_position.size()
	var Tile = tile.instantiate()
	Tile.global_position = spawner_position[index].global_position
	add_child(Tile)

func _on_timer_timeout() -> void:
	spawn_tile()
