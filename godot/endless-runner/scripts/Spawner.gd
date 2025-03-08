extends Node2D

@export var obstacle_scene: PackedScene
@export var reward_scene: PackedScene
@export var spawn_rate: float = 1.5
@export var min_spawn_rate: float = 0.7
@export var difficulty_increase: float = 0.995
@export var base_fall_speed: float = 300.0  # Starting fall speed
var current_fall_speed: float = base_fall_speed
var grapes_collected: int = 0

# Add score tracking
var score: int = 0
signal score_changed(new_score: int)
signal player_hit  # For when player hits obstacle

var lanes = []
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	lanes = [
		get_parent().get_node("Lane1").position.x,
		get_parent().get_node("Lane2").position.x,
		get_parent().get_node("Lane3").position.x
	]
	spawn_timer()

func spawn_object():
	var is_obstacle = rng.randf() < 0.3
	var scene = obstacle_scene if is_obstacle else reward_scene
	
	var obj = scene.instantiate()
	
	# Set the current fall speed for this object
	obj.fall_speed = current_fall_speed
	
	var lane_index = rng.randi() % lanes.size()
	obj.position = Vector2(lanes[lane_index], -100)
	
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 32
	collision.shape = shape
	area.add_child(collision)
	
	# Set collision layer for detection
	area.collision_layer = 2  # Layer 2 for collectibles
	area.collision_mask = 1   # Layer 1 for player
	
	area.body_entered.connect(_on_object_hit.bind(obj, is_obstacle))
	
	obj.add_child(area)
	get_parent().add_child(obj)

func _on_object_hit(body, obj, is_obstacle):
	if body.is_in_group("player"):
		var score_change = -10 if is_obstacle else 5
		if is_obstacle:
			body.hit_bad_object()
			print("Hit burger - lose health!")
			score = max(0, score - 10)  # Lose 10 points
			player_hit.emit()  # Emit signal for player hit
		else:
			body.hit_good_object()
			print("Got grape - gain points!")
			score += 5  # Gain 5 points
			grapes_collected += 1
			# Increase fall speed with each grape collected
			current_fall_speed = base_fall_speed + (grapes_collected * 10)  # Increase by 15 units per grape
				
		score_changed.emit(score)  # Emit signal with new score
		obj.queue_free()  # Remove the object

func spawn_timer():
	await get_tree().create_timer(spawn_rate).timeout
	spawn_object()
	spawn_rate = max(min_spawn_rate, spawn_rate * difficulty_increase)
	spawn_timer()
