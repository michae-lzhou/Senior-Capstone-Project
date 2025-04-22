extends Node
class_name SessionProperties

# user auth object, set after login
var auth_m = null

# profile data, set after login
var username: String = ""
var email: String = ""
var member_since: String = ""

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
#to access: GSession.GStats[GSession.game]["score"]

var G1Score: Array = [
	#1100, 1120, 1130, 1170, 1150, 1180, 1200, 1250
]

var G1Speed: Array = [
	#1100, 1120, 1130, 1170, 1780, 1180, 1200, 1250,
	#1300, 1310, 1290, 1330, 1230, 1400, 1450, 1600
]

var G1PosHitPercent: Array = [
]

var G1NegMissPercent: Array = [
]

var G2Score: Array = [
]

var G2Speed: Array = [
]

var G2PosHitPercent: Array = [
]

var G2NegMissPercent: Array = [
]

var G3Score: Array = [
	#980, 1000, 1040, 1060, 1080, 1100, 1120, 1140,
	#1180, 1220, 1240, 1270, 1300, 1340, 1360, 1000
]

var G3Speed: Array = [
	#980, 1000, 1040, 1060, 1080, 1100, 1120, 1140,
	#1180, 1220, 1240, 1270, 1300, 1340, 1360, 1000
]

var G3PosHitPercent: Array = [
]

var G3NegMissPercent: Array = [
]

var G4Score: Array = [
	#980, 1000, 1040, 1060, 1080, 1100, 1120, 1140,
	#1180, 1220, 1240, 1270, 1300, 1340, 1360, 1000
]

var G4Speed: Array = [
	#980, 1000, 1040, 1060, 1080, 1100, 1120, 1140,
	#1180, 1220, 1240, 1270, 1300, 1340, 1360, 1000
]

var G4PosHitPercent: Array = [
]

var G4NegMissPercent: Array = [
]

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
