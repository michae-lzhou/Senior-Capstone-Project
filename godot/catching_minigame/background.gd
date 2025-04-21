extends Node2D

var score = 0
var lives = 3
var game_is_over = false
var items_frozen = false  # For block functionality

# Labels
var score_label
var lives_label
var block_label

func _ready():
	# Set up timer if it doesn't exist
	if !has_node("Timer"):
		var timer = Timer.new()
		timer.name = "Timer"
		timer.wait_time = randf_range(0.3, 1)
		timer.one_shot = false
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)
		timer.start()
	else:
		$Timer.timeout.connect(_on_timer_timeout)
		$Timer.start(randf_range(0.3, 1))
	
	# Create UI elements
	score_label = Label.new()
	score_label.position = Vector2(10, 10)
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 24)
	add_child(score_label)
	
	lives_label = Label.new()
	lives_label.position = Vector2(10, 40)
	lives_label.text = "Lives: 3"
	lives_label.add_theme_font_size_override("font_size", 24)
	add_child(lives_label)
	
	block_label = Label.new()
	block_label.position = Vector2(10, 70)
	block_label.text = "Block: Ready (Press Space)"
	block_label.add_theme_font_size_override("font_size", 20)
	add_child(block_label)
	
	# Connect signals from player if it exists
	var player = get_node_or_null("Player")
	if !player:
		print("Player node not found - make sure you have a Player node as a child of background")
	else:
		player.connect("block_started", Callable(self, "_on_player_block_started"))
		player.connect("block_ended", Callable(self, "_on_player_block_ended"))

func _process(delta):
	# Check for block activation via spacebar
	if Input.is_action_just_pressed("ui_select") and !game_is_over:
		var player = get_node_or_null("Player")
		if player and player.has_method("try_activate_block"):
			player.try_activate_block()

func _on_timer_timeout():
	if game_is_over:
		return
	
	# Spawn a random object
	var screen = get_viewport_rect().size
	var pos = Vector2(randf_range(30, screen.x - 30), -50)
	
	var is_good = randf() < 0.7  # 70% chance of spawning good object
	var object
	
	if is_good:
		var good_scene = load("res://good.tscn")
		object = good_scene.instantiate()
		object.connect("score_point", Callable(self, "_on_score_point"))
	else:
		var bad_scene = load("res://bad.tscn")
		if bad_scene:
			object = bad_scene.instantiate()
			object.connect("lose_point", Callable(self, "_on_lose_point"))
		else:
			print("Bad scene couldn't be loaded - make sure bad.tscn exists")
			return
	
	object.position = pos
	add_child(object)
	
	# Reset timer
	$Timer.start(randf_range(0.3, 1))

func _on_score_point():
	if game_is_over:
		return
		
	score += 10
	score_label.text = "Score: " + str(score)

func _on_lose_point():
	if game_is_over:
		return
		
	lives -= 1
	lives_label.text = "Lives: " + str(lives)
	
	if lives <= 0:
		game_over()

func game_over():
	game_is_over = true
	
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER\nFinal Score: " + str(score)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 36)
	game_over_label.position = Vector2(get_viewport_rect().size.x / 2 - 100, get_viewport_rect().size.y / 2 - 50)
	add_child(game_over_label)
	
	$Timer.stop()
	
	var restart_button = Button.new()
	restart_button.text = "Restart"
	restart_button.position = Vector2(get_viewport_rect().size.x / 2 - 50, get_viewport_rect().size.y / 2 + 50)
	restart_button.size = Vector2(100, 50)
	restart_button.pressed.connect(Callable(self, "restart_game"))
	add_child(restart_button)

func restart_game():
	get_tree().reload_current_scene()

func is_game_over() -> bool:
	return game_is_over

func are_items_frozen() -> bool:
	return items_frozen

func _on_player_block_started():
	items_frozen = true
	block_label.text = "Block: Active!"
	
	# Add visual feedback
	var overlay = ColorRect.new()
	overlay.name = "BlockOverlay"
	overlay.color = Color(0.2, 0.6, 1.0, 0.2)  # Light blue tint
	overlay.size = get_viewport_rect().size
	overlay.position = Vector2(0, 0)
	add_child(overlay)

func _on_player_block_ended():
	items_frozen = false
	block_label.text = "Block: Cooling Down..."
	
	# Remove visual feedback
	var overlay = get_node_or_null("BlockOverlay")
	if overlay:
		overlay.queue_free()
	
	# Start cooldown timer
	var cooldown_timer = get_tree().create_timer(5.0)
	cooldown_timer.timeout.connect(Callable(self, "_on_block_cooldown_finished"))

func _on_block_cooldown_finished():
	if !game_is_over:
		block_label.text = "Block: Ready (Press Space)"
