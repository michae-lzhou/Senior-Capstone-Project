extends Node

# Current user
var current_user = ""

# Configuration chosen on Pick Your Poison screen
var selected_temptations: Array = []
var selected_powerups: Array = []

# Minigame selected from GameSelection
var selected_minigame: String = ""

# In-game tracking (optional - reset per round)
var current_score: int = 0
var current_round: int = 1

# Optionally store results from past rounds for stats
var game_history: Array = []  # Each item could be a Dictionary with fields like {score, date, game_type}

# Convenience methods
func reset_session():
	current_score = 0
	current_round = 1
