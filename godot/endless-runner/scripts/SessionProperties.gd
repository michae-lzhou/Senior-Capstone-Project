extends Node
class_name SessionProperties

var good_misses: int = 0
var bad_misses: int = 0
var good_hits: int = 0
var bad_hits: int = 0
var reaction_time: Array = []
var session_score: int = 41234
var game: int = 0

var G1Score: Array = [
	Vector2(1, 1100), Vector2(2, 1120), Vector2(3, 1130), Vector2(4, 1170),
	Vector2(5, 1150), Vector2(6, 1180), Vector2(7, 1200), Vector2(8, 1250)
]

var G1Speed: Array = [
	Vector2(1, 1100), Vector2(2, 1120), Vector2(3, 1130), Vector2(4, 1170),
	Vector2(5, 1150), Vector2(6, 1180), Vector2(7, 1200), Vector2(8, 1250),
	Vector2(9, 1300), Vector2(10, 1310), Vector2(11, 1290), Vector2(12, 1330),
	Vector2(13, 1380), Vector2(14, 1400), Vector2(15, 1450)
]

var G1Focus: Array = [
	Vector2(1, 1000), Vector2(2, 970), Vector2(3, 940), Vector2(4, 980),
	Vector2(5, 960), Vector2(6, 1020), Vector2(7, 1100), Vector2(8, 1120),
	Vector2(9, 1080), Vector2(10, 1150), Vector2(11, 1180), Vector2(12, 1200),
	Vector2(13, 1220), Vector2(14, 1240), Vector2(15, 1280)
]

var G2Score: Array = [
	Vector2(1, 900), Vector2(2, 950), Vector2(3, 970), Vector2(4, 1000),
	Vector2(5, 990), Vector2(6, 1010), Vector2(7, 1040), Vector2(8, 1060),
	Vector2(9, 1100), Vector2(10, 1150), Vector2(11, 1180), Vector2(12, 1250),
	Vector2(13, 1300), Vector2(14, 1330), Vector2(15, 1350)
]

var G2Speed: Array = [
	Vector2(1, 950), Vector2(2, 980), Vector2(3, 1000), Vector2(4, 1020),
	Vector2(5, 1080), Vector2(6, 1120), Vector2(7, 1170), Vector2(8, 1230),
	Vector2(9, 1250), Vector2(10, 1280), Vector2(11, 1290), Vector2(12, 1350),
	Vector2(13, 1370), Vector2(14, 1390), Vector2(15, 1410)
]

var G2Focus: Array = [
	Vector2(1, 1200), Vector2(2, 1220), Vector2(3, 1240), Vector2(4, 1260),
	Vector2(5, 1280), Vector2(6, 1300), Vector2(7, 1350), Vector2(8, 1370),
	Vector2(9, 1380), Vector2(10, 1400), Vector2(11, 1410), Vector2(12, 1440),
	Vector2(13, 1460), Vector2(14, 1490), Vector2(15, 1500)
]

var G3Score: Array = [
	Vector2(1, 980), Vector2(2, 1000), Vector2(3, 1040), Vector2(4, 1060),
	Vector2(5, 1080), Vector2(6, 1100), Vector2(7, 1120), Vector2(8, 1140),
	Vector2(9, 1180), Vector2(10, 1220), Vector2(11, 1240), Vector2(12, 1270),
	Vector2(13, 1300), Vector2(14, 1340), Vector2(15, 1360)
]

var G3Speed: Array = [
	Vector2(1, 1000), Vector2(2, 1020), Vector2(3, 1050), Vector2(4, 1070),
	Vector2(5, 1100), Vector2(6, 1130), Vector2(7, 1170), Vector2(8, 1210),
	Vector2(9, 1240), Vector2(10, 1260), Vector2(11, 1290), Vector2(12, 1320),
	Vector2(13, 1360), Vector2(14, 1390), Vector2(15, 1420)
]

var G3Focus: Array = [
	Vector2(1, 950), Vector2(2, 970), Vector2(3, 1000), Vector2(4, 1020),
	Vector2(5, 1050), Vector2(6, 1080), Vector2(7, 1100), Vector2(8, 1130),
	Vector2(9, 1150), Vector2(10, 1180), Vector2(11, 1220), Vector2(12, 1250),
	Vector2(13, 1290), Vector2(14, 1320), Vector2(15, 1350)
]

var G4Score: Array = [
	Vector2(1, 1050), Vector2(2, 1070), Vector2(3, 1090), Vector2(4, 1110),
	Vector2(5, 1140), Vector2(6, 1180), Vector2(7, 1220), Vector2(8, 1250),
	Vector2(9, 1280), Vector2(10, 1320), Vector2(11, 1350), Vector2(12, 1370),
	Vector2(13, 1390), Vector2(14, 1410), Vector2(15, 1450)
]

var G4Speed: Array = [
	Vector2(1, 940), Vector2(2, 970), Vector2(3, 1000), Vector2(4, 1020),
	Vector2(5, 1040), Vector2(6, 1070), Vector2(7, 1100), Vector2(8, 1140),
	Vector2(9, 1180), Vector2(10, 1200), Vector2(11, 1250), Vector2(12, 1280),
	Vector2(13, 1300), Vector2(14, 1340), Vector2(15, 1380)
]

var G4Focus: Array = [
	Vector2(1, 970), Vector2(2, 1000), Vector2(3, 1030), Vector2(4, 1060),
	Vector2(5, 1080), Vector2(6, 1100), Vector2(7, 1130), Vector2(8, 1160),
	Vector2(9, 1180), Vector2(10, 1200), Vector2(11, 1220), Vector2(12, 1250),
	Vector2(13, 1280), Vector2(14, 1300), Vector2(15, 1330)
]

# Optional: A method to reset everything (could be useful between levels or for debugging)
func reset():
	good_misses = 0
	bad_misses = 0
	good_hits = 0
	bad_hits = 0
	reaction_time.clear()
	session_score = 0
	game = 0

	G1Score = []
	G1Speed = []
	G1Focus = []
	G2Score = []
	G2Speed = []
	G2Focus = []
	G3Score = []
	G3Speed = []
	G3Focus = []
	G4Score = []
	G4Speed = []
	G4Focus = []

# Optional: Print method for debugging
func print_stats():
	print("Good Hits:", good_hits)
	print("Bad Hits:", bad_hits)
	print("Good Misses:", good_misses)
	print("Bad Misses:", bad_misses)
	print("Reaction Times:", reaction_time)
	print("Session Score:", session_score)
