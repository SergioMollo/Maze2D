extends Node

const color_red = Color(1,0,0)
const color_green = Color(0,1,0)
const color_blue = Color(0,0,1)

var initial_resolution: Vector2 = Vector2(1920,1080)

var player_texture = "player1.png"
var enemy_texture = "enemy1.png"

var selection = ""

var move_player = false
var move_enemy = false

var configuracion: Dictionary # Se usara para eliminar las siguientes variables
var nivel: VideogameConstants.Nivel
var dificultad: VideogameConstants.Dificultad
var modo_juego: VideogameConstants.ModoJuego
var modo_interaccion: VideogameConstants.ModoInteraccion
var algoritmo: VideogameConstants.Algoritmo
var juegos: int

var maze_size: Vector2i = Vector2i(0,0)
var user_name: String

var partida_reference: String = ""
var nombre_partida: String = ""

signal set_text_info(message: String, color: Color)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func login(email: String, password: String):
	var authentificacion = Firebase.Auth
	authentificacion.login_succeeded.connect(on_login_succeeded)
	authentificacion.login_failed.connect(on_login_failed)
	authentificacion.login_with_email_and_password(email, password) 
	setTextinfo("Iniciando sesion...", color_blue)


func signUp(email: String, password: String, name: String):
	user_name = name
	var authentificacion = Firebase.Auth
	authentificacion.signup_succeeded.connect(on_signup_succeeded)
	authentificacion.signup_failed.connect(on_signup_failed)
	authentificacion.signup_with_email_and_password(email, password) 
	setTextinfo("Creando usuario...", color_blue)


func on_login_succeeded(auth):
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")
	setTextinfo("Sesion Iniciada", color_green)
	

func on_signup_succeeded(auth):
	get_tree().change_scene_to_file("res://Maze/View/UI/InicioSesion.tscn")
	setTextinfo("Registrado completado", color_green)
	saveUser()
	

func on_login_failed(error_code, message):
	setTextinfo("Sesion fallida", color_red)


func on_signup_failed(error_code, message):
	setTextinfo("Registro fallido", color_red)	
	
	
func setTextinfo(message: String, color: Color):
	emit_signal("set_text_info", message, color)
	
	
func saveUser():
	var auth = Firebase.Auth.auth
	if auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection("usuario")
		var usuario: Dictionary = {
			"email": auth.email,
			"nombre": user_name,
			"partidas": []
		}
		collection.add(auth.localid, usuario)


func save(partida: Dictionary, jugador: Dictionary, enemigo: Dictionary, juego: Dictionary, moneda: Dictionary, camino_jugador: Dictionary, camino_enemigo: Dictionary):
	var auth = Firebase.Auth.auth
	var usuario_collection: FirestoreCollection = Firebase.Firestore.collection("usuario")
	var partida_collection: FirestoreCollection = Firebase.Firestore.collection("partida")	
	var jugador_collection: FirestoreCollection = Firebase.Firestore.collection("jugador")
	var enemigo_collection: FirestoreCollection = Firebase.Firestore.collection("enemigo")	
	var juego_collection: FirestoreCollection = Firebase.Firestore.collection("juego")
	var moneda_collection: FirestoreCollection = Firebase.Firestore.collection("moneda")	
	var camino_collection: FirestoreCollection = Firebase.Firestore.collection("camino")
	var partida_document: FirestoreDocument
	
	
	if partida_reference == "":
		if !camino_jugador.is_empty():		
			var camino_document = await camino_collection.add("", camino_jugador)		
			jugador["id_camino"] = camino_document.doc_name
			
		var jugador_document = await jugador_collection.add("", jugador)
		partida["id_jugador"] = jugador_document.doc_name
		
		if !enemigo.is_empty():
			var camino_document = await camino_collection.add("", camino_enemigo)
			enemigo["id_camino"] = camino_document.doc_name
			var enemigo_document = await enemigo_collection.add("", enemigo)
			partida["id_enemigo"] = enemigo_document.doc_name
			
		var juego_document = await juego_collection.add("", juego)
		partida["id_juego"] = juego_document.doc_name
		
		var moneda_document = await moneda_collection.add("", moneda)
		partida["id_moneda"] = moneda_document.doc_name
		
		partida_document = await partida_collection.add("", partida)
		partida_reference = partida_document.doc_name	
		
		var usuario_document = await usuario_collection.get_doc(auth.localid)
		var partidas = usuario_document.get_value("partidas")
		partidas.append(partida_document.doc_name)
		usuario_document.add_or_update_field("partidas", partidas)
		usuario_collection.update(usuario_document)

	else:
		partida_document = await partida_collection.get_doc(partida_reference)	
		var jugador_reference = partida_document.get_value("id_jugador")
		var moneda_reference = partida_document.get_value("id_moneda")
		var juego_reference = partida_document.get_value("id_juego")
		
		var jugador_document = await jugador_collection.get_doc(jugador_reference)
		var moneda_document = await moneda_collection.get_doc(moneda_reference)
		var juego_document = await juego_collection.get_doc(juego_reference)	
	
		if !camino_jugador.is_empty():
			var camino_jugador_reference = jugador_document.get_value("id_camino")
			var camino_jugador_document = await camino_collection.get_doc(camino_jugador_reference)
			jugador["id_camino"] = camino_jugador_reference
			
			for key in camino_jugador.keys():
				camino_jugador_document.add_or_update_field(key, camino_jugador[key])
				camino_collection.update(camino_jugador_document)
				
		for key in jugador.keys():
			jugador_document.add_or_update_field(key, jugador[key])
		jugador_collection.update(jugador_document)

		if !enemigo.is_empty():
			var enemigo_reference = partida_document.get_value("id_enemigo")
			var enemigo_document = await enemigo_collection.get_doc(enemigo_reference)
			var camino_enemigo_reference = enemigo_document.get_value("id_camino")
			var camino_enemigo_document = await camino_collection.get_doc(camino_enemigo_reference)
			
			enemigo["id_camino"] = camino_enemigo_reference
			partida["id_enemigo"] = enemigo_reference
			for key in enemigo.keys():
				enemigo_document.add_or_update_field(key, enemigo[key])		
			enemigo_collection.update(enemigo_document)
			
			for key in camino_enemigo.keys():
				camino_enemigo_document.add_or_update_field(key, camino_enemigo[key])
			camino_collection.update(camino_enemigo_document)

		for key in moneda.keys():
				moneda_document.add_or_update_field(key, moneda[key])
		moneda_collection.update(moneda_document)
		
		for key in juego.keys():
				juego_document.add_or_update_field(key, juego[key])
		juego_collection.update(juego_document)
	
		partida["id_jugador"] = jugador_reference
		partida["id_juego"] = juego_reference
		partida["id_moneda"] = moneda_reference
		
		for key in partida.keys():
			partida_document.add_or_update_field(key, partida[key])
		partida_collection.update(partida_document)
		
	
func loadGames():
	var auth = Firebase.Auth.auth
	var usuario_collection: FirestoreCollection = Firebase.Firestore.collection("usuario")
	var partida_collection: FirestoreCollection = Firebase.Firestore.collection("partida")	
	var partida_document: FirestoreDocument
	
	var user_games = await usuario_collection.get_doc(auth.localid)
	var partidas = user_games.get_value("partidas")
	var lista_partidas = []
	
	for partida in partidas:
		lista_partidas.append(await partida_collection.get_doc(partida))
		
	return lista_partidas
	
	
func initSaveGame(partida: Dictionary):
	pass
