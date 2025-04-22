class_name db_utils

static var USER_COLLECTION = "users"

# push_to_db
# auth: Firebase.Auth object of logged in user
# collection_path (String): path to collection containing document to push to
# document_name (String): name of document to push to
# create_new (true): in case of missing document, create new document with given name and payload
static func push_to_db(auth, collection_path : String, document_name : String, payload : Dictionary, create_new = true):
	print("[PUSH] pushing data to collection \"" + collection_path + "\", document \"" + document_name + "\" doc")
	
	if auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(collection_path)
		var doc : FirestoreDocument = await collection.get_doc(document_name)
		
		if doc:
			print("[PUSH] found document, updating..")
			for key in payload.keys():
				doc.add_or_update_field(key, payload[key])
				
			var task = await collection.update(doc)
			if task:
				print("[PUSH] SUCCESS document updated successfully")
			else:
				print("[PUSH] FAILED to udpate document")
				return false
		else:
			print("[PUSH] ERROR document not found")
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
static func pull_from_db(auth, collection_path : String, document_name : String, key : String, create_new = true):
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
			print("[PULL] ERROR no document \"" + document_name + "\" found")
			if create_new:
				print("[PULL] Creating new document \"" + document_name + "\"")
				var new_doc = await collection.add(document_name)
				print("[PULL] document added successfully: " + new_doc.doc_name)
			return null

# initializes session properties with user info
static func init_user_properties(auth):
	print("START: [SET_USER_PROPERTIES] setting user info properties..")

	print("[SET_USER_PROPERTIES] setting username..")
	SessionProperties.username = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "username")
	print("[SET_USER_PROPERTIES] succesfully set username")
	
	print("[SET_USER_PROPERTIES] setting email..")
	SessionProperties.email = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "email")
	print("[SET_USER_PROPERTIES] sucessfuly set set email")
	
	print("[SET_USER_PROPERTIES] setting member since date..")
	SessionProperties.member_since = await db_utils.pull_from_db(auth, USER_COLLECTION, auth.localid, "member_since")
	print("[SET_USER_PROPERTIES] sucessfuly set set member since date")
	
	print("END: [SET_USER_PROPERTIES]")
