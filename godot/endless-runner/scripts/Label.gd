extends Label

func _ready():
	# Wait one frame to ensure Spawner is ready
	await get_tree().process_frame
	
	# Use get_node_or_null to check if node exists
	var spawner = get_node_or_null("../../Spawner")
	if spawner:
		spawner.score_changed.connect(_on_score_changed)
		text = "Score: 0"
	else:
		print("ERROR: Couldn't find Spawner node!")

func _on_score_changed(new_score):
	text = "Score: " + str(new_score)
