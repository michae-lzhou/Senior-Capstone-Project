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
				print("[PUSH] FAILED to udpate document")
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

# initializes session properties with user info
static func init_user_properties(auth):
	print("START: [SET_USER_PROPERTIES] setting user info properties..")
	
	print("[SET_USER_PROPERTIES] setting auth..")
	GSession.auth_m = auth
	print("[SET_USER_PROPERTIES] succesfully set auth")

	print("[SET_USER_PROPERTIES] setting username..")
	GSession.username = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "username")
	print("[SET_USER_PROPERTIES] succesfully set username")
	
	print("[SET_USER_PROPERTIES] setting email..")
	GSession.email = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "email")
	print("[SET_USER_PROPERTIES] sucessfuly set set email")
	
	print("[SET_USER_PROPERTIES] setting member since date..")
	GSession.member_since = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "member_since")
	print("[SET_USER_PROPERTIES] sucessfuly set set member since date")
	
	var stats_path = db_utils.USER_COLLECTION + "/" + GSession.auth_m.localid + "/" + db_utils.STATS_COLLECTION
	
	print("[SET_USER_PROPERTIES] setting game2 stats..")
	var G2Score_score = await db_utils.pull_from_db(auth, stats_path, "game2", score_key)
	if G2Score_score:
		GSession.G2Score = G2Score_score
		GSession.G2PosHitPercent = await db_utils.pull_from_db(auth, stats_path, "game2", pos_key)
		GSession.G2NegMissPercent = await db_utils.pull_from_db(auth, stats_path, "game2", neg_key)
		GSession.G2Speed = await db_utils.pull_from_db(auth, stats_path, "game2", speed_key)
		print("[SET_USER_PROPERTIES] sucessfully set game2 stats")
	else:
		print("[SET_USER_PROPERTIES] no game2 stats found in database, did not set")
		
	#GSession.G2Score = await db_utils.pull_from_db(auth, stats_path, "game2", score_key)
	#GSession.G2PosHitPercent = await db_utils.pull_from_db(auth, stats_path, "game2", pos_key)
	#GSession.G2NegMissPercent = await db_utils.pull_from_db(auth, stats_path, "game2", neg_key)
	#GSession.G2Speed = await db_utils.pull_from_db(auth, stats_path, "game2", speed_key)
	
	GSession.print_G2()
	
	print("END: [SET_USER_PROPERTIES]")
