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

# rating weighting
var recent = 0.7
var global = 1 - recent

# ranks: each rank is (max_rating/num_ranks) rating apart
var rank_partitions = {
#	game_idx : [max rating, num of ranks]
	1 : [500, 5],
	2 : [500, 5],
	3 : [500, 5],
	4 : [500, 5]
}

var rank_names = ["Novice", "Intermediate", "Proficient", "Advanced", "Expert", "👑 Master 👑"]

# the slowest reaction time one can have for each game (time item stays on screen at lowest difficulty)
var max_react_times = {
	1 : 5.0,
	2 : 5.0,
	3 : 5.0,
	4 : 5.0
}

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
		 "avg_react_time" : 0.0,
 		 "rank" : 0
		},
	2 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": [],
		 "score_rating": 0.0,
		 "avg_react_time" : 0.0,
 		 "rank" : 0
		},
	3 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": [],
		 "score_rating": 0.0,
		 "avg_react_time" : 0.0,
 		 "rank" : 0
		},
	4 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": [],
		 "score_rating": 0.0,
		 "avg_react_time" : 0.0,
 		 "rank" : 0
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
		 "avg_react_time" : 0.0,
 		 "rank" : 0
		},
	2 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": [],
		 "score_rating": 0.0,
		 "avg_react_time" : 0.0,
 		 "rank" : 0
		},
	3 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": [],
		 "score_rating": 0.0,
		 "avg_react_time" : 0.0,
 		 "rank" : 0
		},
	4 : {
		 "score":    [],
		 "speed":    [],
		 "pos_hit":  [],
		 "neg_miss": [],
		 "score_rating": 0.0,
		 "avg_react_time" : 0.0,
 		 "rank" : 0
		}
}

static func calc_rating(data : Array, num_recent = 3, weight_recent = 0.6, weight_top = 0.3):
	if data.size() < 1:
		print("[RATING CALC] No Scores in data array")
		return 0.0
	
	var score_total = 0.0
	for score in data:
		score_total += score
	var total_avg = score_total / float(data.size())
	#print("[RATING CALC] total average:", total_avg)
	
	var score_recent = 0.0
	num_recent = min(num_recent, data.size())
	var recent_data = data.slice(-num_recent)
	
	for score in recent_data:
		score_recent += score
		
	var recent_avg = score_recent / float(num_recent)
	#print("[RATING CALC] recent average: ", recent_avg)
	
	var top_score : float = float(data.max())
	#print("[RATING CALC] top score: ", top_score)
	
	var weight_total = 1 - weight_recent - weight_top
	var weighted_avg = (total_avg * weight_total) + (recent_avg * weight_recent) + (top_score * weight_top)
	print("[RATING CALC] weighted mean: ", weighted_avg)
	
	return weighted_avg

func get_rank(score_rating, game_idx):
	#print("[RANK] score: ", score_rating)
	var partition = rank_partitions[game_idx]
	
	if score_rating >= partition[0]:
#		maximum rank - only when at or above highest rating
		return partition[1]
		
	for x in range(partition[1] - 1, -1, -1):
		if score_rating >= (x/float(partition[1]) * partition[0]):
			return x
			
	return 0

# updates user's game rating and rank. uses GStats
func update_rating(game_idx):
	var score_rating = calc_rating(GStats[game_idx]["score"])
	var avg_react_time = calc_rating(GStats[game_idx]["speed"], 3, 0.5, 0.0)
	
	GSession.GStats[game_idx]["score_rating"] = score_rating
	print("[UPDATE RATING] sucessfully updated score rating")
	
	GSession.GStats[game_idx]["avg_react_time"] = avg_react_time
	print("[UPDATE RATING] sucessfully updated average speed")
	
	var new_rank = get_rank(score_rating, game_idx)
	GSession.GStats[game_idx]["rank"] = new_rank
	print("[UPDATE RATING] sucessfully updated rank")
	print("[UPDATE RATING] current rank: ", new_rank)
