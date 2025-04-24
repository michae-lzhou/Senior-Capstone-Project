extends Node
class_name SessionProperties

# number of minigames
var num_games = 4

# user auth object, set after login
var auth_m = null

# profile data, set after login
var username: String = ""
var email: String = ""
var member_since: String = ""
var streak : int = 1

# game data
var good_misses: float = 0.0
var bad_misses: float = 0.0
var good_hits: float = 0.0
var bad_hits: float = 0.0
var good_hit_percent: float = 0.0
var bad_miss_percent: float = 0.0
var good_reaction_time: Array = []
var bad_reaction_time: Array = []
var session_score: int = 0
var game: int = 0
var salient_idx = 0

var GStats = {
	1 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": []
		},
	2 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": []
		},
	3 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": []
		},
	4 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": []
		}
}

# resets game session relevant information
func reset():
	good_misses = 0
	bad_misses = 0
	good_hits = 0
	bad_hits = 0
	good_hit_percent = 0
	bad_miss_percent = 0
	good_reaction_time.clear()
	bad_reaction_time.clear()
	session_score = 0
	game = 0

# purely for debugging purposes
func print_G2():
	print("Scores:", GStats[2]["score"])
	print("Speed:", GStats[2]["speed"])
	print("Pos hit:", GStats[2]["pos_hit"])
	print("Neg missed:", GStats[2]["neg_miss"])
	
func print_stats():
	print("Good Hits:", good_hits)
	print("Bad Hits:", bad_hits)
	print("Good Misses:", good_misses)
	print("Bad Misses:", bad_misses)
	print("Good Reaction Times:", good_reaction_time)
	print("Bad Reaction Times:", bad_reaction_time)
	print("Session Score:", session_score)
	
# used on logout
func wipe_session_data():
	auth_m = null

	username = ""
	email = ""
	member_since = ""
	streak = 1
	
	good_misses = 0.0
	bad_misses = 0.0
	good_hits = 0.0
	bad_hits = 0.0
	good_hit_percent = 0.0
	bad_miss_percent = 0.0
	good_reaction_time = []
	bad_reaction_time = []
	session_score = 0
	game = 0
	salient_idx = 0

	GStats = {
	1 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": []
		},
	2 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": []
		},
	3 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": []
		},
	4 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": []
		}
	}
