extends Node2D

var good = preload("res://good.tscn")
var bad = preload("res://bad.tscn")  # You'll need to create this scene
var t = randf_range(0.3, 1)
var score = 0
var lives = 3  # Add lives system

# Create labels to display the score and lives
var score_label
var lives_label

func _ready():
	$Timer.start(t)
	
	# Create a score label
	score_label = Label.new()
	score_label.position = Vector2(10, 10)
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 24)
	add_child(score_label)
	
	# Create a lives label
	lives_label = Label.new()
	lives_label.position = Vector2(10, 40)
	lives_label.text = "Lives: 3"
	lives_label.add_theme_font_size_override("font_size", 24)
	add_child(lives_label)

func _on_timer_timeout():
	var screen = get_viewport_rect().size
	var pos = Vector2(randf_range(0, screen.x), -600)
	
	# Randomly choose between spawning a good or bad object
	var object_scene
	if randf() < 0.7:  # 70% chance to spawn good object
		object_scene = load("res://good.tscn")
	else:  # 30% chance to spawn bad object
		object_scene = load("res://bad.tscn")
	
	var object = object_scene.instantiate()
	object.position = pos
	
	# Connect appropriate signals
	if object_scene == good:
		object.score_point.connect(_on_score_point)
	else:
		object.lose_point.connect(_on_lose_point)
	
	add_child(object)
	
	# Reset timer with random time
	t = randf_range(0.3, 1)
	$Timer.start(t)

# Add this function to handle the score increment
func _on_score_point():
	score += 10
	score_label.text = "Score: " + str(score)

# Add this function to handle losing lives
func _on_lose_point():
	lives -= 1
	lives_label.text = "Lives: " + str(lives)
	
	# Game over condition
	if lives <= 0:
		game_over()

# Game over function
func game_over():
	# You can create a game over screen or restart the game
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER\nFinal Score: " + str(score)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 36)
	game_over_label.position = Vector2(get_viewport_rect().size.x / 2 - 100, get_viewport_rect().size.y / 2 - 50)
	add_child(game_over_label)
	
	# Stop the timer to prevent more objects from spawning
	$Timer.stop()
	
	# Add a restart button
	var restart_button = Button.new()
	restart_button.text = "Restart"
	restart_button.position = Vector2(get_viewport_rect().size.x / 2 - 50, get_viewport_rect().size.y / 2 + 50)
	restart_button.size = Vector2(100, 50)
	restart_button.pressed.connect(restart_game)
	add_child(restart_button)

# Function to restart the game
func restart_game():
	# Reload the current scene
	get_tree().reload_current_scene()
