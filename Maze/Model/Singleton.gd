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
var email: String = "sergio@mail"

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



func saveGame(partida: Dictionary, nivel_information: Dictionary, jugador: Dictionary, enemigo: Dictionary, juego: Dictionary, camino_jugador: Dictionary, camino_enemigo: Dictionary, ids: Dictionary):

	var database_api = Database.new()
	database_api.initDatabase()


	if partida_reference == "":
		database_api.addResource("juego", juego)
		partida["id_juego"] = database_api.getLastInsertId()
		database_api.addResource("nivel", nivel_information)
		partida["id_nivel"] = database_api.getLastInsertId()

		
		if !camino_jugador.is_empty():
			database_api.addResource("camino_jugador", camino_jugador)
			jugador["id_camino"] = database_api.getLastInsertId()

		database_api.addResource("jugador", jugador)
		partida["id_jugador"] = database_api.getLastInsertId()

		if !enemigo.is_empty():
			database_api.addResource("camino_enemigo", camino_enemigo)
			enemigo["id_camino"] = database_api.getLastInsertId()
			database_api.addResource("enemigo", enemigo)
			partida["id_enemigo"] = database_api.getLastInsertId()
		
		partida["email_usuario"] = email
		database_api.addResource("partida", partida)

	else:
		database_api.updateResource("partida", partida, partida_reference)
		database_api.updateResource("nivel", nivel_information, ids["id_nivel"])
		database_api.updateResource("jugador", jugador, ids["id_jugador"])	
		database_api.updateResource("juego", juego, ids["id_juego"])
		
		if !camino_jugador.is_empty():
			database_api.updateResource("camino_jugador", camino_jugador, ids["id_camino_jugador"])

		if !enemigo.is_empty():
			database_api.updateResource("enemigo", enemigo, ids["id_enemigo"])
			database_api.updateResource("camino_enemigo", camino_enemigo, ids["id_camino_enemigo"])

	database_api.closeDatabase()






	
func loadGames():
	var database_api = Database.new()
	database_api.initDatabase()
	
	database_api.closeDatabase()
	
	
	
func initSaveGame(partida: Dictionary):
	pass
	


func deleteGame(name: String, id: String):
	var database_api = Database.new()
	database_api.initDatabase()
	database_api.deleteResource(name, id)
	database_api.closeDatabase()



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
		Singleton.modo_interaccion = VideogameConstants.ModoInteraccion.MODO_SIMULACION

	Singleton.juegos = partida["juegos"]

	if partida["algoritmo_jugador"] == 0:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.BFS
	elif partida["algoritmo_jugador"] == 1:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.DFS
	elif partida["algoritmo_jugador"] == 2:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.DIJKSTRA
	elif partida["algoritmo_jugador"] == 3:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.A_STAR
	elif partida["algoritmo_jugador"] == -1:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.EMPTY

	if partida["algoritmo_enemigo"] == 0:
		Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.BFS
	elif partida["algoritmo_enemigo"] == 1:
		Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.DFS
	elif partida["algoritmo_enemigo"] == 2:
		Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.DIJKSTRA
	elif partida["algoritmo_enemigo"] == 3:
		Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.A_STAR
	elif partida["algoritmo_enemigo"] == -1:
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
