extends Node

const color_red = Color(1,0,0)
const color_green = Color(0,1,0)
const color_blue = Color(0,0,1)

var initial_resolution: Vector2 = Vector2(1920,1080)

var player_texture = "res://Resources/PixelArt/player1.png"
var enemy_texture = "res://Resources/PixelArt/enemy1.png"

var selection = ""

var move_player = false
var move_enemy = false

var configuracion: Dictionary # Se usara para eliminar las siguientes variables
var nivel: VideogameConstants.Nivel
var dificultad: VideogameConstants.Dificultad
var modo_juego: VideogameConstants.ModoJuego
var modo_interaccion: VideogameConstants.ModoInteraccion
var algoritmo: VideogameConstants.Algoritmo
var algoritmo_jugador: VideogameConstants.Algoritmo
var algoritmo_enemigo: VideogameConstants.Algoritmo
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
		
		var partida_document = await partida_collection.add("", partida)
		partida_reference = partida_document.doc_name	
		
		var usuario_document = await usuario_collection.get_doc(auth.localid)
		var partidas = usuario_document.get_value("partidas")
		partidas.append(partida_document.doc_name)
		usuario_document.add_or_update_field("partidas", partidas)
		usuario_collection.update(usuario_document)

	else:
		var partida_document = await partida_collection.get_doc(partida_reference)	
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
	var jugador_collection: FirestoreCollection = Firebase.Firestore.collection("jugador")
	var enemigo_collection: FirestoreCollection = Firebase.Firestore.collection("enemigo")	

	var user_games = await usuario_collection.get_doc(auth.localid)
	var partidas = user_games.get_value("partidas")

	var lista_partidas = []
	var lista_partidas_finalizadas = []
	
	for partida in partidas:
		var partida_document = await partida_collection.get_doc(partida)
		var jugador = partida_document.get_value("id_jugador")
		var enemigo = partida_document.get_value("id_enemigo")
		var jugador_document = await jugador_collection.get_doc(jugador)
		var enemigo_document = await enemigo_collection.get_doc(enemigo)
		
		partida_document.add_or_update_field("algoritmo_jugador", jugador_document.get_value("algoritmo"))
		if enemigo_document.doc_name != "":
			partida_document.add_or_update_field("algoritmo_enemigo", enemigo_document.get_value("algoritmo"))
		
		partida_document.add_or_update_field("reference", partida)
		
		if partida_document.get_value("estado") == 3:
			lista_partidas_finalizadas.append(partida_document.get_unsafe_document())
		else:
			lista_partidas.append(partida_document.get_unsafe_document())
		
	return [lista_partidas, lista_partidas_finalizadas]
	
	
func initSaveGame(partida: Dictionary):
	
	var new_scene = configureGame(partida)	

	Singleton.nombre_partida = partida["nombre"]
	Singleton.partida_reference = partida["reference"]
	
	# Aqui hay que rellenar partida con los datos de posiciones y todos los objetos que se requieran, es decir, obtener
	# los datos de cada instancia y pasarlas a la escena para despues asignar
	var partida_collection: FirestoreCollection = Firebase.Firestore.collection("partida")
	var jugador_collection: FirestoreCollection = Firebase.Firestore.collection("jugador")
	var enemigo_collection: FirestoreCollection = Firebase.Firestore.collection("enemigo")	
	var juego_collection: FirestoreCollection = Firebase.Firestore.collection("juego")
	var moneda_collection: FirestoreCollection = Firebase.Firestore.collection("moneda")	
	var camino_collection: FirestoreCollection = Firebase.Firestore.collection("camino")

	var partida_document = await partida_collection.get_doc(partida_reference)
	var jugador_reference = partida_document.get_value("id_jugador")
	var enemigo_reference = partida_document.get_value("id_enemigo")
	var jugador_document = await jugador_collection.get_doc(jugador_reference)
	var enemigo_document = await enemigo_collection.get_doc(enemigo_reference)
	
	var jugador = jugador_document.get_unsafe_document()
	var juego_reference = partida_document.get_value("id_juego")
	var moneda_reference = partida_document.get_value("id_moneda")
	
	var camino_jugador_reference = jugador_document.get_value("id_camino")
	
	var enemigo = {}
	var camino_enemigo_reference
	var camino_enemigo: Dictionary = {}
	if enemigo_document.doc_name != "":
		enemigo = enemigo_document.get_unsafe_document()
		camino_enemigo_reference = enemigo_document.get_value("id_camino")
		var camino_enemigo_document = await camino_collection.get_doc(camino_enemigo_reference)
		camino_enemigo = camino_enemigo_document.get_unsafe_document()
	
	var juego = await juego_collection.get_doc(juego_reference)
	juego = juego.get_unsafe_document()
	var moneda = await moneda_collection.get_doc(moneda_reference)
	moneda = moneda.get_unsafe_document()
	var camino_jugador = {} 
	if camino_jugador_reference != "":
		var camino_jugador_document = await camino_collection.get_doc(camino_jugador_reference)
		camino_jugador = camino_jugador_document.get_unsafe_document()
	
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
	new_scene.asignValues(partida, jugador, juego, moneda, enemigo, camino_jugador, camino_enemigo)


func configureGame(partida: Dictionary):
	
	if partida["dificultad"] == 0:
		Singleton.dificultad = VideogameConstants.Dificultad.FACIL
	elif partida["dificultad"] == 1:
		Singleton.dificultad = VideogameConstants.Dificultad.MEDIA
	else :
		Singleton.dificultad = VideogameConstants.Dificultad.DIFICIL

	if partida["modo_juego"] == 0:
		Singleton.modo_juego = VideogameConstants.ModoJuego.MODO_SOLITARIO
	else:
		Singleton.modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO

	if partida["modo_interaccion"] == 0:
		Singleton.modo_interaccion = VideogameConstants.ModoInteraccion.MODO_USUARIO
	else:
		Singleton.modo_interaccion = VideogameConstants.ModoInteraccion.MODO_COMPUTADORA

	Singleton.juegos = partida["juegos"]

	if partida["algoritmo_jugador"] == 0:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.BFS
	elif partida["algoritmo_jugador"] == 1:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.DFS
	elif partida["algoritmo_jugador"] == 2:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.DIJKSTRA
	elif partida["algoritmo_jugador"] == 3:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.A_STAR
	elif partida["algoritmo_jugador"] == 4:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.EMPTY
		
	if partida.has("algoritmo_enemigo"):
		if partida["algoritmo_enemigo"] == 0:
			Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.BFS
		elif partida["algoritmo_enemigo"] == 1:
			Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.DFS
		elif partida["algoritmo_enemigo"] == 2:
			Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.DIJKSTRA
		elif partida["algoritmo_enemigo"] == 3:
			Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.A_STAR
		elif partida["algoritmo_enemigo"] == 4:
			Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.EMPTY

	var new_scene
	if partida["nivel"] == 0:
		Singleton.nivel = VideogameConstants.Nivel.NIVEL1
		new_scene = load("res://Maze/View/Game/LaberintoNivel1.tscn").instantiate()
	elif partida["nivel"] == 1:
		Singleton.nivel = VideogameConstants.Nivel.NIVEL2
		new_scene = load("res://Maze/View/Game/LaberintoNivel2.tscn").instantiate()
	elif partida["nivel"] == 2:
		Singleton.nivel = VideogameConstants.Nivel.NIVEL3
		new_scene = load("res://Maze/View/Game/LaberintoNivel3.tscn").instantiate()
	elif partida["nivel"] == 3:
		Singleton.nivel = VideogameConstants.Nivel.ALEATORIO
		new_scene = load("res://Maze/View/Game/LaberintoAleatorio.tscn").instantiate()
	
	return new_scene


func getNivelString(value: int):
	return VideogameConstants.Nivel.keys()[value]
	
	
func getModoJuegoString(value: int):
	return VideogameConstants.ModoJuego.keys()[value]
	
	
func getModoInteraccionString(value: int):
	return VideogameConstants.ModoInteraccion.keys()[value]
	
	
func getDificultadString(value: int):
	return VideogameConstants.Dificultad.keys()[value]
	
	
func getAlgoritmoString(value: int):
	return VideogameConstants.Algoritmo.keys()[value]
	
	
func getEstadoPartidaString(value: int):
	return VideogameConstants.EstadoPartida.keys()[value]
	
	
func getEstadoJuegoString(value: int):
	return VideogameConstants.EstadoPartida.keys()[value]
