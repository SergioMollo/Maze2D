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

var nivel: VideogameConstants.Nivel
var dificultad: VideogameConstants.Dificultad
var modo_juego: VideogameConstants.ModoJuego
var modo_interaccion: VideogameConstants.ModoInteraccion
var algoritmo_jugador: VideogameConstants.Algoritmo
var algoritmo_enemigo: VideogameConstants.Algoritmo
var juegos: int

var maze_size: Vector2i = Vector2i(0,0)

var usuario: User

signal set_text_info(message: String, color: Color)
signal save_completed


# Inica los datos cuando se instancia por primera vez
func _ready():
	pass


# Inicia sesion con el usuario y contraseña introducidos
# 	- Comprueba que las credenciales sean correctas
func login(user_email: String, user_password: String):

	var database_api = Database.new()
	database_api.initDatabase()
	var result = database_api.getUser(user_email)

	if !result.is_empty() and result["password"] == user_password:
		usuario = User.new()	
		usuario.setEmail(result["email"])
		usuario.setPassword(result["password"])
		usuario.setNombre(result["nombre"])
		loginSucceeded()
	else:
		loginFailed()

	database_api.closeDatabase()


# Crea un usuario y contraseña
# 	- Comprueba que el email no exista
func signUp(user_email: String, user_password: String, user_name: String):

	var database_api = Database.new()
	database_api.initDatabase()
	var result = database_api.getUser(user_email)

	if result.is_empty():

		var user: Dictionary = {
			"nombre": user_name,
			"email": user_email,
			"password": user_password
		}

		database_api.addResource("usuario", user)
		signupSucceeded()

	else:
		signupFailed()

	database_api.closeDatabase()


# Muestra el mensaje de sesion iniciada correctamente
func loginSucceeded():
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")
	setTextinfo("Sesion Iniciada", color_green)
	

# Muestra el mensaje de registro completado correctamente
func signupSucceeded():
	get_tree().change_scene_to_file("res://Maze/View/UI/InicioSesion.tscn")
	setTextinfo("Registrado completado", color_green)


# Muestra el mensaje de sesion fallida
func loginFailed():
	setTextinfo("Sesion fallida, credenciales incorrectos", color_red)


# Muestra el mensaje de sesion iniciada correctamente
func signupFailed():
	setTextinfo("Registro fallido, cuenta existente", color_red)	
	

# Muestra el mensaje de registro fallido
func setTextinfo(message: String, color: Color):
	emit_signal("set_text_info", message, color)	

	
# Guarda la partida con los datos necesarios
# 	- Añade cada recurso en una tabla diferente, asignando los identificadores correspondientes
# 	- Comprueba que la partida ya ha sido guardada anteriormente, en su caso, actualiza los datos
func guardarPartida(partida: Dictionary, level_data: Dictionary, jugador: Dictionary, enemigo: Dictionary, juego: Dictionary, camino_jugador: Dictionary, camino_enemigo: Dictionary, ids: Dictionary = {}):

	var database_api = Database.new()
	database_api.initDatabase()

	if ids["id_partida"] == -1:
		database_api.addResource("juego", juego)
		partida["id_juego"] = database_api.getLastInsertId()
		database_api.addResource("nivel", level_data)
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
		
		partida["email_usuario"] = usuario.getEmail()
		database_api.addResource("partida", partida)

	else:
		database_api.updateResource("partida", partida, ids["id_partida"])
		database_api.updateResource("nivel", level_data, ids["id_nivel"])
		database_api.updateResource("jugador", jugador, ids["id_jugador"])	
		database_api.updateResource("juego", juego, ids["id_juego"])
		
		if !camino_jugador.is_empty():
			database_api.updateResource("camino_jugador", camino_jugador, ids["id_camino_jugador"])

		if !enemigo.is_empty():
			database_api.updateResource("enemigo", enemigo, ids["id_enemigo"])
			database_api.updateResource("camino_enemigo", camino_enemigo, ids["id_camino_enemigo"])

	database_api.closeDatabase()
	emit_signal("save_completed")


# Carga las partidas guardadas por un usuario
# 	- Obtiene las partidas del usuario con la sesion iniciada para mostrarlas en la lista
func cargarPartidasGuardadas():
	var database_api = Database.new()
	database_api.initDatabase()
	var enCurso = database_api.getPartidasEnCurso(usuario.getEmail())
	var finalizadas = database_api.getPartidasFinalizadas(usuario.getEmail())
	database_api.closeDatabase()
	return [enCurso, finalizadas]
	
	
# Carga los datos de la partida selecionada
# 	- Inicia la partida seleccionada
func continuaPartida(partida: Dictionary):
	var database_api = Database.new()
	database_api.initDatabase()
	
	var camino_jugador = {}
	var enemigo = {}
	var camino_enemigo = {}

	var juego = database_api.getJuego(partida["id_juego"])
	var jugador = database_api.getJugador(partida["id_juego"])
	
	if jugador["id_camino"] != null:
		camino_jugador = database_api.getCamino(jugador[0]["id_camino"])
		partida.get_or_add(jugador["algoritmo"])
		
	if partida["id_enemigo"] != null:
		enemigo = database_api.getEnemigo(partida["id_enemigo"])
		camino_enemigo = database_api.getCamino(enemigo[0]["id_camino"])
		partida.get_or_add(enemigo["algoritmo"])
		
	var nivel_partida = database_api.getNivel(partida["id_nivel"])
	partida.get_or_add(nivel_partida["nivel"])
	nivel_partida = splitLevelValues(nivel_partida)

	var new_scene = configurarPartida(partida)
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
	new_scene.asignValues(partida, jugador, juego, nivel_partida, enemigo, camino_jugador, camino_enemigo)

	database_api.closeDatabase()
	

# Borra una partida seleccionada de la base de datos
func borrarPartida(nombre: String, id: String):
	var database_api = Database.new()
	database_api.initDatabase()
	database_api.deleteResource(nombre, id)
	database_api.closeDatabase()


# Configura los datos de la partida mediante los datos seleccionados al crear la partida
# 	- Establece los datos de configuración de la partida
func configurarPartida(partida: Dictionary):
	
	if partida["dificultad"] == 0:
		dificultad = VideogameConstants.Dificultad.FACIL
	elif partida["dificultad"] == 1:
		dificultad = VideogameConstants.Dificultad.MEDIA
	else :
		dificultad = VideogameConstants.Dificultad.DIFICIL

	if partida["modo_juego"] == 0:
		modo_juego = VideogameConstants.ModoJuego.MODO_SOLITARIO
	else:
		modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO

	if partida["modo_interaccion"] == 0:
		modo_interaccion = VideogameConstants.ModoInteraccion.MODO_USUARIO
	else:
		modo_interaccion = VideogameConstants.ModoInteraccion.MODO_SIMULACION

	juegos = partida["numero_juegos"]

	if partida["algoritmo_jugador"] == 0:
		algoritmo_jugador = VideogameConstants.Algoritmo.BFS
	elif partida["algoritmo_jugador"] == 1:
		algoritmo_jugador = VideogameConstants.Algoritmo.DFS
	elif partida["algoritmo_jugador"] == 2:
		algoritmo_jugador = VideogameConstants.Algoritmo.DIJKSTRA
	elif partida["algoritmo_jugador"] == 3:
		algoritmo_jugador = VideogameConstants.Algoritmo.A_STAR
	elif partida["algoritmo_jugador"] == -1:
		algoritmo_jugador = VideogameConstants.Algoritmo.EMPTY

	if partida["algoritmo_enemigo"] == 0:
		algoritmo_enemigo = VideogameConstants.Algoritmo.BFS
	elif partida["algoritmo_enemigo"] == 1:
		algoritmo_enemigo = VideogameConstants.Algoritmo.DFS
	elif partida["algoritmo_enemigo"] == 2:
		algoritmo_enemigo = VideogameConstants.Algoritmo.DIJKSTRA
	elif partida["algoritmo_enemigo"] == 3:
		algoritmo_enemigo = VideogameConstants.Algoritmo.A_STAR
	elif partida["algoritmo_enemigo"] == -1:
		algoritmo_enemigo = VideogameConstants.Algoritmo.EMPTY

	var new_scene
	if partida["nivel"] == 0:
		nivel = VideogameConstants.Nivel.NIVEL1
		new_scene = load("res://Maze/View/Game/LaberintoNivel1.tscn").instantiate()
	elif partida["nivel"] == 1:
		nivel = VideogameConstants.Nivel.NIVEL2
		new_scene = load("res://Maze/View/Game/LaberintoNivel2.tscn").instantiate()
	elif partida["nivel"] == 2:
		nivel = VideogameConstants.Nivel.NIVEL3
		new_scene = load("res://Maze/View/Game/LaberintoNivel3.tscn").instantiate()
	elif partida["nivel"] == 3:
		nivel = VideogameConstants.Nivel.ALEATORIO
		new_scene = load("res://Maze/View/Game/LaberintoAleatorio.tscn").instantiate()
	
	return new_scene


# Asigna los valores de configuracion del nivel en el formato correcto
func splitLevelValues(level_data: Dictionary):
	var value
	
	value = level_data.maze_size.split(",")
	level_data.maze_size = Vector2(int(value[0]), int(value[1]))
	value = level_data.scale.split(",")
	level_data.scale = Vector2(int(value[0]), int(value[1]))
	value = level_data.initial_player_position.split(",")
	level_data.initial_player_position = Vector2(int(value[0]), int(value[1]))
	value = level_data.initial_enemy_position.split(",")
	level_data.initial_enemy_position = Vector2(int(value[0]), int(value[1]))
	value = level_data.initial_coin_position.split(",")
	level_data.initial_coin_position = Vector2(int(value[0]), int(value[1]))
	
	return level_data


# Obtiene la cadena de texto correspondiente al tipo de Nivel
func getNivelString(value: int):
	return VideogameConstants.Nivel.keys()[value]
	

# Obtiene la cadena de texto correspondiente al Modo de Juego
func getModoJuegoString(value: int):
	return VideogameConstants.ModoJuego.keys()[value]
	

# Obtiene la cadena de texto correspondiente al Modo de Interaccion
func getModoInteraccionString(value: int):
	return VideogameConstants.ModoInteraccion.keys()[value]
	
	
# Obtiene la cadena de texto correspondiente al tipo de Dificultad
func getDificultadString(value: int):
	return VideogameConstants.Dificultad.keys()[value]
	
	
# Obtiene la cadena de texto correspondiente al tipo de Algoritmo
func getAlgoritmoString(value: int):
	return VideogameConstants.Algoritmo.keys()[value]
	

# Obtiene la cadena de texto correspondiente al Estado de la Partida	
func getEstadoPartidaString(value: int):
	return VideogameConstants.EstadoPartida.keys()[value]
	

# Obtiene la cadena de texto correspondiente al Estado del Juego	
func getEstadoJuegoString(value: int):
	return VideogameConstants.EstadoPartida.keys()[value]
