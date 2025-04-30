extends Control

func _ready():
	$Game1Button.pressed.connect(_on_game1_pressed)
	$Game2Button.pressed.connect(_on_game2_pressed)
	$Game3Button.pressed.connect(_on_game3_pressed)
	#$Game4Button.pressed.connect(_on_game4_pressed)
	$BackButton.pressed.connect(_on_back_pressed)

func _on_game1_pressed():
	GSession.reset()
	print("Starting Game: Snap Judgement...")
	GSession.game = 1
	get_tree().change_scene_to_file("res://scenes/SnapJudgement.tscn")
	
func _on_game2_pressed():
	GSession.reset()
	print("Starting Game: Slice Warrior...")
	GSession.game = 2
	get_tree().change_scene_to_file("res://scenes/SliceWarrior.tscn")
	
#func _on_game3_pressed():
	#GSession.reset()
	#GSession.game = 3
	#print("Starting Game: Crave Catcher...")

func _on_game3_pressed():
	GSession.reset()
	GSession.game = 3
	print("Starting Game: Impulse Aisle...")
	get_tree().change_scene_to_file("res://scenes/ImpulseAisle.tscn")
		
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
