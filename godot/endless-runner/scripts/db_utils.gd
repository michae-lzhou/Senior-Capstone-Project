class_name db_utils

static var USER_COLLECTION = "users"
static var STATS_COLLECTION = "stats"

# database keys for user stats arrays
static var score_key : String = "scores"
static var pos_key : String = "positive_hit_percents"
static var neg_key : String = "negative_miss_percents"
static var speed_key : String = "average_reaction_speeds"

# push_to_db
# auth: Firebase.Auth object of logged in user
# collection_path (String): path to collection containing document to push to
# document_name (String): name of document to push to
# create_new (true): in case of missing document, create new document with given name and payload
static func push_to_db(auth, collection_path : String, document_name : String, payload : Dictionary, create_new : bool = true):
	print("[PUSH] pushing data to collection \"" + collection_path + "\", document \"" + document_name + "\" doc")
	
	if auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(collection_path)
		var doc : FirestoreDocument = await collection.get_doc(document_name)
		
		if doc:
			print("[PUSH] found document: " + document_name +", updating..")
			for key in payload.keys():
				doc.add_or_update_field(key, payload[key])
				
			var task = await collection.update(doc)
			if task:
				print("[PUSH] SUCCESS document updated successfully")
			else:
				print("[PUSH] FAILED to update document")
				return false
		else:
			print("[PUSH] WARNING document not found")
			if create_new:
				print("[PUSH] creating new document \"" + document_name + "\"")
				var new_doc = await collection.add(document_name, payload)
				if new_doc:
					print("[PUSH] document added and updated successfully: " + new_doc.doc_name)
					return true
				else:
					print("[PUSH] unable to create new document. Action likely unpermitted")
			return false
		return true
	else:
		print("[PUSH] ERROR, no localid found")
		return false

# pull_from_db
# auth: Firebase.Auth object of logged in user
# collection_path (String): path to collection containing document to pull from
# document_name (String): name of document to pull from
# create_new (bool): default true. in case of missing document, create new empty document with given name
static func pull_from_db(auth, collection_path : String, document_name : String, key : String, create_new : bool = true):
	print("[PULL] pulling data from collection \"" + collection_path + "\", document \"" + document_name + "\" doc")
	
	if auth.localid:
		var collection : FirestoreCollection = Firebase.Firestore.collection(collection_path)
		var doc : FirestoreDocument = await collection.get_doc(document_name)
		
		if doc:
			var val = doc.get_value(key)
			if val:
				print("[PULL] SUCCESS retrived value for: " + key)
				return val
			else:
				print("[PULL] FAILED to retrive value for: " + key +". Key likely missing")
				return null
		else:
			print("[PULL] WARNING no document \"" + document_name + "\" found")
			if create_new:
				print("[PULL] Creating new document \"" + document_name + "\"")
				var new_doc = await collection.add(document_name)
				print("[PULL] document added successfully: " + new_doc.doc_name)
			return null

# initializes session properties with user info and stats
static func init_user_properties(auth, loading_label):
	print("START: [INIT_SESSION_INFO] setting user info properties..")

	print("[INIT_SESSION_INFO] clearing any session data")
	GSession.wipe_session_data()
	print("[INIT_SESSION_INFO] successfully cleared session")
	
	loading_label.text = "Logging in.."
	print("[INIT_SESSION_INFO] pulling streak and last login time..")
	
#	previous login time that counted towards streak
	var prev_login = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "last_login")
	var prev_streak_login = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "last_streak_login")
	var streak = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "streak")
	
	var curr_login = Time.get_unix_time_from_system()
	
	var payload = {"last_login" : curr_login}
	var day_s = 86400
	
#	time threshold for streak expiration (in days). default 48 hours
	var streak_thresh = 2
	if prev_login and streak:
		print("[INIT_SESSION_INFO] calculating current streak")
#		find time since last login (max 48 hours: 12 am of day one to 11:59pm day two)
		var days_since = (curr_login - prev_login) / day_s
		var days_since_streak_count = (curr_login - prev_streak_login) / day_s
		
		print("[INIT_SESSION_INFO] days since last login: " + str(days_since))
		print("[INIT_SESSION_INFO] days since last streak increase: " + str(days_since_streak_count))
#		check time within 48 hours, and been at least a day since last streak increase
		if days_since <= streak_thresh and days_since_streak_count >= 1:
			print("[INIT_SESSION_INFO] adding to streak!")
			streak += 1
			payload["last_streak_login"] = curr_login
		elif days_since > streak_thresh:
#			reset streak
			print("[INIT_SESSION_INFO] too many days since last login")
			streak = 1
		else:
#			otherwise, streak stays same, and we just update last login
			print("[INIT_SESSION_INFO] has not been a day since last streak increase")
			
	else:
		print("[INIT_SESSION_INFO] no previous login or streak, setting streak to 1")
		payload["last_streak_login"] = curr_login
		streak = 1
		
	payload["streak"] = streak
	print("[INIT_SESSION_INFO] pushing current login and streak of " + str(streak) + " to db..")
	await db_utils.push_to_db(auth, USER_COLLECTION, auth.localid, payload)
	
	GSession.streak = streak
	print("[INIT_SESSION_INFO] successfully set streak in session")
	
	loading_label.text = "Loading user info.."
	print("[INIT_SESSION_INFO] setting auth..")
	GSession.auth_m = auth
	print("[INIT_SESSION_INFO] succesfully set auth")
		
	print("[INIT_SESSION_INFO] setting username..")
	GSession.username = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "username")
	print("[INIT_SESSION_INFO] succesfully set username")
	
	print("[INIT_SESSION_INFO] setting email..")
	GSession.email = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "email")
	print("[INIT_SESSION_INFO] sucessfuly set set email")
	
	print("[INIT_SESSION_INFO] setting member since date..")
	GSession.member_since = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "member_since")
	print("[INIT_SESSION_INFO] sucessfuly set set member since date")
	
	loading_label.text = "Loading user game stats.."
	var stats_path = db_utils.USER_COLLECTION + "/" + GSession.auth_m.localid + "/" + db_utils.STATS_COLLECTION
	
	for game_idx in range(1, (1 + GSession.num_games)):
		print("[INIT_SESSION_INFO] setting game ", game_idx, " stats..")
		var game_str = "game" + str(game_idx)
		
		var db_scores = await db_utils.pull_from_db(auth, stats_path, game_str, score_key)
	
		if db_scores:
			GSession.GStats[game_idx]["score"] = db_scores
			
			var react_times = await db_utils.pull_from_db(auth, stats_path, game_str, speed_key)
			GSession.GStats[game_idx]["speed"] = react_times
			GSession.GStats[game_idx]["pos_hit"] = await db_utils.pull_from_db(auth, stats_path, game_str, pos_key)
			GSession.GStats[game_idx]["neg_miss"] = await db_utils.pull_from_db(auth, stats_path, game_str, neg_key)
			print("[INIT_SESSION_INFO] sucessfully set game ", game_idx, " stats")
			
			GSession.update_rating(game_idx)
			print("[INIT_SESSION_INFO] sucessfully set game ", game_idx, " rating and rank")
			
			#
			#var score_rating = GSession.calc_rating(db_scores, 3, 0.5, 0.3)
			#var avg_react_time = GSession.calc_rating(react_times, 3, 0.5, 0.0)
			#
			#GSession.GStats[game_idx]["score_rating"] = score_rating
			#print("[INIT_SESSION_INFO] sucessfully set score rating")
			#
			#GSession.GStats[game_idx]["avg_react_time"] = avg_react_time
			#print("[INIT_SESSION_INFO] sucessfully set speed rating")
			#
			#GSession.GStats[game_idx]["rank"] = GSession.get_rank(score_rating, game_idx)
			#print("[INIT_SESSION_INFO] sucessfully set rank")
		else:
			print("[INIT_SESSION_INFO] no game ", game_idx, " stats found in database, did not set")
		
		
	loading_label.text = "Done!"
	print(GSession.GStats)
	
	print("END: [INIT_SESSION_INFO]")
