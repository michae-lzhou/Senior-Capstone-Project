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

# elo weighting
var recent = 0.7
var global = 1 - recent

# game data (transient)
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

# user stats (persistent, stored in db)
var 	GStats = {
		1 : {
			 "score":    [],
			 "speed":    [],
			 "pos_hit":  [],
			 "neg_miss": [],
			 "score_rating": 0.0,
			 "speed_rating" : 0.0
			},
		2 : {
			 "score":    [],
			 "speed":    [],
			 "pos_hit":  [],
			 "neg_miss": [],
			 "score_rating": 0.0,
			 "speed_rating" : 0.0
			},
		3 : {
			 "score":    [],
			 "speed":    [],
			 "pos_hit":  [],
			 "neg_miss": [],
			 "score_rating": 0.0,
			 "speed_rating" : 0.0
			},
		4 : {
			 "score":    [],
			 "speed":    [],
			 "pos_hit":  [],
			 "neg_miss": [],
			 "score_rating": 0.0,
			 "speed_rating" : 0.0
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
	#game = 0

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
			 "neg_miss": [],
			 "score_rating": 0.0,
			 "speed_rating" : 0.0
			},
		2 : {
			 "score":    [],
			 "speed":    [],
			 "pos_hit":  [],
			 "neg_miss": [],
			 "score_rating": 0.0,
			 "speed_rating" : 0.0
			},
		3 : {
			 "score":    [],
			 "speed":    [],
			 "pos_hit":  [],
			 "neg_miss": [],
			 "score_rating": 0.0,
			 "speed_rating" : 0.0
			},
		4 : {
			 "score":    [],
			 "speed":    [],
			 "pos_hit":  [],
			 "neg_miss": [],
			 "score_rating": 0.0,
			 "speed_rating" : 0.0
			}
	}

func calc_rating(data : Array, num_recent = 3, weight_recent = 0.7):
	if data.size() < 1:
		print("[RATING CALC] No Scores in data array")
		return 0.0
	
	var score_total = 0.0
	for score in data:
		score_total += score
	var total_avg = score_total / float(data.size())
	print("[RATING CALC] total average:", total_avg)
	
	var score_recent = 0.0
	num_recent = min(num_recent, data.size())
	var recent_data = data.slice(-num_recent)
	
	for score in recent_data:
		score_recent += score
		
	var recent_avg = score_recent / float(num_recent)
	print("[RATING CALC] recent average:", recent_avg)
	
	var weight_total = 1 - weight_recent
	var weighted_avg = (total_avg * weight_total) + (recent_avg * weight_recent)
	print("[RATING CALC] weighted average:", weighted_avg)
	
	return weighted_avg
