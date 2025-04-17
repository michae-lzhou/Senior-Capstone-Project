extends Node2D

var score = 0
var lives = 3

@onready var score_label = $HUD/ScoreLabel
@onready var spawner = $Spawner
@onready var slice_trail = $SliceTrail
@onready var floating_text_scene := preload("res://scenes/FloatingText.tscn")

var trail_points = []
const MAX_TRAIL_POINTS = 15

func _input(event):
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		# Add trail point
		trail_points.append(event.position)
		if trail_points.size() > MAX_TRAIL_POINTS:
			trail_points.pop_front()
		slice_trail.points = trail_points

		# Slice detection
		var space = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = event.position

		var result = space.intersect_point(query)

		if result.size() > 0:
			var collider = result[0].collider
			if collider and collider.is_in_group("sliceable") and collider.has_method("on_sliced"):
				collider.on_sliced()

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		# Clear trail when mouse released
		trail_points.clear()
		slice_trail.points = []


func _ready():
	update_score()
	spawner.start()

func update_score():
	score_label.text = "Score: " + str(score)

func on_good_sliced(pos: Vector2):
	score += 10
	update_score()
	show_floating_text("+10", pos, Color.GREEN)

func on_bad_sliced(pos: Vector2):
	score -= 10
	update_score()
	show_floating_text("-10", pos, Color.RED)
	if score < 0:
		end_game()

func show_floating_text(text: String, pos: Vector2, color: Color):
	var label = floating_text_scene.instantiate()
	label.text = text
	label.position = pos
	label.modulate = color
	add_child(label)

func on_sliced():
	get_tree().current_scene.on_good_sliced(global_position)  # or on_bad_sliced
	queue_free()

func end_game():
	get_tree().change_scene_to_file("res://scenes/EndGame.tscn")
	#get_tree().change_scene_to_file("res://scenes/GameSelection.tscn")  # or Results screen
