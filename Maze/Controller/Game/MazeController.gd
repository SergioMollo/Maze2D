extends Node2D

class_name MazeController

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

var maze: Maze
var game: Game

var win = 0
var lose = 0
var initiate: bool = false
 
var map = []
var graph = {}
var ids = {
	"id_partida": -1
}

@export var enemy_scene: PackedScene

@onready var player: CharacterBody2D = $"../Jugador"
@onready var coin: Area2D = $"../Moneda/Moneda2D"
@onready var header = $"../Layer/Header/Layer/Panel"
@onready var winLabel : Label  = $"../Layer/LabelWin"
@onready var loseLabel : Label  = $"../Layer/LabelLose"
@onready var timeExceedLabel : Label  = $"../Layer/LabelTimeExceed"
@onready var finishLabel : Label  = $"../Layer/LabelFinish"
@onready var timeLabel : Label  = $"../Layer/Header/Layer/Panel/Container/Time/ValueTime/LabelTime"
@onready var timer : Timer  = $"../Timer"
@onready var tilemap = $"../TileMap"


# Inica los datos cuando se instancia por primera vez
func _ready():
	Videogame.stopMusic()
	Videogame.setGameMusic()
	await get_tree().create_timer(0.5).timeout


# Asigna los valores de configuración (posiciones iniciales, tamaños, tiempo...) al modelo del laberinto
func setupData(level_data : Dictionary):
	winLabel.hide()
	loseLabel.hide()
	
	var nivel_label : Label  = $"../Layer/Header/Layer/Panel/Container/LabelNivel"	
	nivel_label.text = Videogame.getNivelString(Videogame.nivel)
	
	maze = Maze.new(level_data, player, coin, timer, tilemap)
	game = Game.new(level_data.time)
	maze.moneda.hide()
	maze.moneda.coin.connect("collected", mostrarResultado)
	
	get_window().content_scale_size = maze.scale
	header.size.x = maze.scale.x
	

	

# Inicia las posiciones de los elementos
func initPositions(pos: Vector2):
	Videogame.move_enemy = false
	maze.jugador.position = pos	
	maze.jugador.player.position = pos	
	maze.jugador.player.target = pos
	maze.jugador.player.actual_position = pos
	maze.moneda.position = maze.initial_coin_position


# Inicia los datos de configuracion, y en su defecto, recrea el mapa de tiles
func initGame(level_data : Dictionary):
	setupData(level_data)
	if Videogame.nivel == VideogameConstants.Nivel.ALEATORIO:
		recreateMaze(level_data.map, level_data.scale)
	createMap(maze.maze_size.x, maze.maze_size.y)

	if Videogame.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		maze.jugador.setAlgorithm(Videogame.algoritmo_jugador, graph)
	nuevoJuego()

		
# Crea un nuevo juego, asignando las configuraciones iniciales
# 	- Inicia las posiciones de los personajes
# 	- Oculta los mensajes irrelevantes
#  	- Genera el enemigo en el Modo Enfrentamiento
#  	- Inicia el contador de tiempo
func nuevoJuego():
	initiate = false
	timeLabel.text = str("--")
	
	var init_time = $"../Layer/Time"
	init_time.position = Vector2(maze.scale.x/2-25,maze.scale.y/2-75)
	init_time.text = "5"
	init_time.show()
	deshabilitaConfiguracion()
	
	await get_tree().create_timer(1.0).timeout
	maze.timer.start(6)
	while maze.timer.time_left > 1:
		init_time.text = str(int(maze.timer.time_left - 1))
		await get_tree().create_timer(0.1).timeout
		if maze.timer.time_left == 1:
			maze.timer.stop()
			
	init_time.text = "¡YA!"	
	await get_tree().create_timer(0.5).timeout
		
	init_time.hide()
	winLabel.hide()
	loseLabel.hide()
	game.numero += 1
	
	initPositions(maze.initial_player_position)

	if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		spawnEnemy(maze.initial_enemy_position)
	maze.jugador.player.maze_finished = false
	
	if game.estado != 1:
		maze.timer.start(maze.time)
		gameProcess()


# Procesa las fisicas del juego, se ejecuta continuamente
# 	- Actualiza el contador de tiempo
func _process(delta):
	if initiate:
		while maze.timer.time_left > 0:
			timeLabel.text = str(int(maze.timer.time_left))
			await get_tree().create_timer(1.0).timeout 
	

#  Proceso del juego, determina el modo de juego, y crea los caminos en casa de requerrirlo
func gameProcess():
	initiate = true
	maze.moneda.show()
	
	var algorithm = AlgorithmController.new()
	algorithm.graph = graph
	var heuristic = {}
	var trayectory = []
	var scene = get_tree().get_current_scene()

	createHeuristic(algorithm, heuristic)

	if Videogame.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_USUARIO and Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_SOLITARIO:
		habilitaConfiguracion()
	else:
		deshabilitaConfiguracion()
		# Para modo usuario interactivo y enfrentandose al enemigo
		if Videogame.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_USUARIO and Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
			await searchPath(algorithm, trayectory, scene)

			while initiate:
				if maze.enemigo.enemy.path.trayectoria.size() > 0:
					await moveOneStep(algorithm)
					Videogame.move_enemy = false
					if Videogame.algoritmo_enemigo == VideogameConstants.Algoritmo.DIJKSTRA or Videogame.algoritmo_enemigo == VideogameConstants.Algoritmo.A_STAR:
						var path_enemigo = await newSearch(Videogame.algoritmo_enemigo, algorithm, heuristic, maze.enemigo.position, maze.jugador.position, maze.moneda.position)
						if !path_enemigo.is_empty():
							await maze.enemigo.setPath(maze.enemigo.position, maze.jugador.position, path_enemigo)
				else:
					Videogame.move_enemy = false
					break

		# Para DFS y BFS con y sin enemigo
		elif Videogame.algoritmo_jugador == VideogameConstants.Algoritmo.BFS or Videogame.algoritmo_jugador == VideogameConstants.Algoritmo.DFS:
			await searchPath(algorithm, trayectory, scene)

			while initiate:	
				if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
					if maze.enemigo.enemy.path.trayectoria.size() > 0:
						await moveOneStep(algorithm)
						Videogame.move_enemy = false
						var path_enemigo = await newSearch(Videogame.algoritmo_enemigo, algorithm, heuristic, maze.enemigo.position, maze.jugador.position, maze.moneda.position)
						if !path_enemigo.is_empty():
							await maze.enemigo.setPath(maze.enemigo.position, maze.jugador.position, path_enemigo)
					else:
						Videogame.move_enemy = false
						await moveOneStepPlayer(algorithm)
				else:
					await moveOneStepPlayer(algorithm)
				

		# Para DFS y BFS del enemigo y Dijkstra y A Estrella para jugador
		elif Videogame.algoritmo_enemigo == VideogameConstants.Algoritmo.BFS or Videogame.algoritmo_enemigo == VideogameConstants.Algoritmo.DFS:		
			await searchPath(algorithm, trayectory, scene)
			algorithm.setValueIsPlayer(true)

			while initiate:	
				if maze.enemigo.enemy.path.trayectoria.size() > 0:
					await moveOneStep(algorithm)
					var path_jugador = await newSearch(Videogame.algoritmo_jugador, algorithm, heuristic, maze.jugador.position, maze.initial_coin_position, maze.enemigo.position)
					if !path_jugador.is_empty():
						await maze.jugador.setPath(maze.jugador.position, maze.initial_coin_position, path_jugador)
				else:
					Videogame.move_enemy = false
					break		

		# Resto de casos, ambos tienen algoritmos dijkstra o a estrella
		else:
			while initiate:
				await searchPath(algorithm, trayectory, scene)
				await moveOneStep(algorithm) 
				createHeuristic(algorithm, heuristic)


func createHeuristic(algorithm: AlgorithmController, heuristic: Dictionary):
	if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		heuristic = algorithm.createHeuristic(maze.maze_size.x, maze.maze_size.y, maze.jugador.position)
		algorithm.setEnemyHeuristic(heuristic)

	if Videogame.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		heuristic = algorithm.createHeuristic(maze.maze_size.x, maze.maze_size.y, maze.moneda.position)
		algorithm.setPlayerHeuristic(heuristic)



# Busqueda del camino/trayectoria que conecta dos elementos
func searchPath(algorithm: AlgorithmController, trayectory: Array, scene):
	if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		trayectory = await algorithm.search(maze.jugador.position, maze.initial_coin_position, tilemap, scene, maze.enemigo.position)
		await maze.enemigo.setPath(maze.jugador.position, maze.initial_coin_position, trayectory[1])
	else:
		trayectory = await algorithm.search(maze.jugador.position, maze.initial_coin_position, tilemap, scene)
		
	await maze.jugador.setPath(maze.jugador.position, maze.initial_coin_position, trayectory[0])


# Repite la busqueda del camino/trayectoria que conecta dos elementos cuando el algoritmo es A Estrella o Dijkstra
func newSearch(algorithm_type: VideogameConstants.Algoritmo, algorithm: AlgorithmController, heuristic: Dictionary, start_node: Vector2, end_node: Vector2, avoid_position: Vector2):
	var path = []
	if algorithm_type == VideogameConstants.Algoritmo.DIJKSTRA:
		createHeuristic(algorithm, heuristic)
		path = await algorithm.dijkstraSearch(start_node, end_node, avoid_position)
	elif algorithm_type == VideogameConstants.Algoritmo.A_STAR:
		createHeuristic(algorithm, heuristic)
		path = await algorithm.aStarSearch(start_node, end_node, algorithm.heuristic_player, avoid_position)

	return path


# Mueve un nodo cada personaje, esperando a completar el movimiento
# 	- Borra los tiles que ha recorrido cada personaje
func moveOneStep(algorithm: AlgorithmController):
	# maze.timer.start()

	if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		if maze.enemigo.enemy.path.trayectoria.size() > 0:
			maze.enemigo.desplazarse()
			await maze.enemigo.movement_finished	
			algorithm.setTilesPath([], maze.enemigo.enemy.path.trayectoria)
			if Videogame.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_USUARIO:
				await maze.jugador.movement_finished

	await moveOneStepPlayer(algorithm) 


# Mueve un nodo para el jugador, esperando a completar el movimiento
# 	- Borra los tiles que ha recorrido cada personaje
func moveOneStepPlayer(algorithm: AlgorithmController):				
	if maze.jugador.player.path.trayectoria.size() > 0:
		maze.jugador.desplazarse()
		algorithm.setTilesPath(maze.jugador.player.path.trayectoria, [])
		await maze.jugador.movement_finished
		

# Inicia el temporizador desde un valor determinado
func continueTimer(time: int):
	maze.timer.start(time)


# Detiene y almacena el valor del temporizador en ese instante
func stopTimer():
	game.tiempo_restante = int(maze.timer.time_left)
	maze.timer.stop()
	

# Crea un enemigo y lo situa en la posicion concreta
func spawnEnemy(enemy_position: Vector2):
	maze.enemigo = enemy_scene.instantiate()
	maze.enemigo.position = enemy_position
	maze.enemigo.connect("eliminated", mostrarEliminado)
	maze.jugador.enemy = maze.enemigo
	get_parent().add_child(maze.enemigo)
	maze.enemigo.maze_finished = false
	maze.enemigo.setAlgorithm(Videogame.algoritmo_enemigo, graph)
	

# Muestra el resultado de victoria
# 	- Aumenta en 1 el numero de victorias del jugador y actualiza la puntuacion
#  	- Elimina al enemigo
# 	- Espera 5 segundos hasta iniciar el siguiente juego
func mostrarResultado():
	initiate = false
	win += 1
	maze.timer.stop()

	winLabel.position = Vector2(maze.scale.x/2-126,maze.scale.y-60)
	winLabel.show()
	maze.moneda.hide()
	actualizaPuntuacion()
	await get_tree().create_timer(2.0).timeout
	if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		maze.enemigo.maze_finished = true
		maze.enemigo.enemy.queue_free() 
	
	habilitaConfiguracion()
	maze.jugador.player.maze_finished = true
	await get_tree().create_timer(3.0).timeout

	if game.numero < Videogame.juegos:
		nuevoJuego()
	else:
		winLabel.hide()
		finishLabel.position = Vector2(maze.scale.x/2-170,maze.scale.y-60)
		finishLabel.show()


# Muestra el resultado de derrota por alcance del enemigo
# 	- Aumenta en 1 el numero de victorias del enemigo y actualiza la puntuacion
#  	- Elimina al enemigo
# 	- Espera 5 segundos hasta iniciar el siguiente juego
func mostrarEliminado():
	initiate = false
	maze.timer.stop()
	maze.jugador.player.maze_finished = true
	maze.enemigo.maze_finished = true

	lose += 1
	loseLabel.position = Vector2(maze.scale.x/2-125,maze.scale.y-60)
	loseLabel.show()

	maze.enemigo.queue_free() 
	habilitaConfiguracion()
	maze.moneda.hide()
	actualizaPuntuacion()
	await get_tree().create_timer(5.0).timeout

	if game.numero < Videogame.juegos:
		nuevoJuego()
	else:
		loseLabel.hide()
		finishLabel.position = Vector2(maze.scale.x/2-170,maze.scale.y-60)
		finishLabel.show()


# Muestra el resultado de derrota por exceso de tiempo
# 	- Aumenta en 1 el numero de victorias del enemigo/computadora y actualiza la puntuacion
#  	- Elimina al enemigo
# 	- Espera 5 segundos hasta iniciar el siguiente juego
func _on_timer_timeout():
	initiate = false
	maze.timer.stop()
	habilitaConfiguracion()
	maze.jugador.player.maze_finished = true
	lose += 1

	if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		maze.enemigo.maze_finished = true
		maze.enemigo.queue_free()

	timeExceedLabel.position = Vector2(maze.scale.x/2-125,maze.scale.y-60)
	loseLabel.show()
	actualizaPuntuacion()
	await get_tree().create_timer(5.0).timeout

	if game.numero < Videogame.juegos:
		nuevoJuego()
	else:
		loseLabel.hide()
		finishLabel.position = Vector2(maze.scale.x/2-170,maze.scale.y-60)
		finishLabel.show()
		

# Actualiza la etiqueta de puntuacion de la cabecera
func actualizaPuntuacion():
	var puntuation : Label  = $"../Layer/Header/Layer/Panel/Container/Result/Results/LabelResultado"	
	puntuation.text = str(win) + "-" + str(lose)


# Deshabilita el boton de configuración
func deshabilitaConfiguracion():
	var config = $"../Layer/Header/Layer/Panel/Container/Configuration"
	config.disabled = true
	maze.timer.stop()
	timeLabel.text = str("--")


# Habilita el boton de configuración
func habilitaConfiguracion():
	var config = $"../Layer/Header/Layer/Panel/Container/Configuration"
	config.disabled = false


# Crea el array con los datos del laberinto (celdas con colision y sin colision)
func createMap(x_size: int, y_size:int):
	
	for i in range(80, y_size+64, pixels_move):
		var row = []
		for j in range(80, x_size+64, pixels_move):
			var cell = tilemap.local_to_map(Vector2(j, i))
			var id = tilemap.get_cell_source_id(0, cell)
			row.append(id)
		map.append(row)

	createGraph(x_size, y_size)


# Crea el grafo que se utilizara para obtener las trayectorias de cada camino
# 	- Asigna los nodos anexos a cada nodo en los que puede realizar movimiento
func createGraph(xSize: int, ySize: int):

	var childs = []
	for i in range(1, ySize/pixels_move - 1):
		for j in range(1, xSize/pixels_move - 1):
			if map[i][j] == 0:
				if map[i][j+1] == 0:
					childs.append(Vector2(pixels_center + pixels_move*(j+1) + pixels_offset, pixels_center + pixels_move*i + pixels_offset))
				if map[i+1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*j + pixels_offset, pixels_center + pixels_move*(i+1) + pixels_offset))
				if map[i-1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*j + pixels_offset, pixels_center + pixels_move*(i-1) + pixels_offset))	
				if map[i][j-1] == 0:
					childs.append(Vector2(pixels_center + pixels_move*(j-1) + pixels_offset, pixels_center + pixels_move*i + pixels_offset))								
				
				graph[Vector2(pixels_center + pixels_move*j + pixels_offset, pixels_center + pixels_move*i + pixels_offset)] = childs
				childs = []


# Crea los diccionarios de datos relevantes de la partida para su guardado
#  	y posterior carga y continuacion
func guardarPartida(nombre: String):
	maze.nombre_partida = nombre
	
	var partida: Dictionary = {
		"nombre": nombre,
		"estado": maze.match_state,
		"resultado": str(win) + "," + str(lose),
		"numero_juegos": Videogame.juegos,
		"dificultad": Videogame.dificultad,
		"modo_juego": Videogame.modo_juego,
		"modo_interaccion": Videogame.modo_interaccion,
		"fecha": Time.get_date_string_from_system()
	}

	var mapa: String = ""
	for node in graph:
		#var node = tilemap.local_to_map(i)
		mapa += str(node.x) + "," + str(node.y) + ";"

	var nivel: Dictionary = {
		"nivel": Videogame.nivel,
		"maze_size": str(maze.maze_size.x) + "," + str(maze.maze_size.y),
		"scale": str(maze.scale.x) + "," + str(maze.scale.y),
		"initial_player_position": str(maze.initial_player_position.x) + "," + str(maze.initial_player_position.y),
		"initial_enemy_position": str(maze.initial_enemy_position.x) + "," + str(maze.initial_enemy_position.y),
		"initial_coin_position": str(maze.initial_coin_position.x) + "," + str(maze.initial_coin_position.y),
		"map": mapa
	}
	
	var jugador: Dictionary = {
		"posicion": str(maze.jugador.position.x) + "," +  str(maze.jugador.position.y),
		"algoritmo": Videogame.algoritmo_jugador,
		"apariencia": Videogame.player_texture,
	}
	
	var enemigo: Dictionary = {}
	var camino_enemigo: Dictionary = {}
	if maze.enemigo != null:
		enemigo = {
			"posicion": str(maze.enemigo.position.x) + "," +  str(maze.enemigo.position.y),
			"algoritmo": Videogame.algoritmo_enemigo,
			"apariencia": Videogame.enemy_texture,
		}
		
		var trayectoria: String = ""
		for node in maze.enemigo.path.trayectoria:
			trayectoria += str(node.x) + "," + str(node.y) + ";"
		
		camino_enemigo = {
			"inicio": str(maze.enemigo.position.x) + "," + str(maze.enemigo.position.y),
			"objetivo": str(maze.jugador.position.x) + "," + str(maze.jugador.position.y),
			"trayectoria": trayectoria
		}
	
	var juego: Dictionary = {
		"numero": game.numero,
		"estado": game.estado,
		"tiempo_restante": int(game.tiempo_restante),
	}
	
	
	var camino_jugador: Dictionary
	if Videogame.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		var trayectoria: String = ""
		for node in maze.jugador.path.trayectoria:
			trayectoria += str(node.x) + "," + str(node.y) + ";"
		
		camino_jugador = {
			"inicio": str(maze.jugador.position.x) + "," + str(maze.jugador.position.y),
			"objetivo": str(maze.coin.position.x) + "," + str(maze.coin.position.y),
			"trayectoria": trayectoria
		}

	Videogame.guardarPartida(partida, nivel, jugador, enemigo, juego, camino_jugador, camino_enemigo, ids)


# Recupera los datos de la partida cargada y establece la configuración y progreso obtenido
func continuarPartida(partida : Dictionary, jugador: Dictionary, juego: Dictionary, level_data: Dictionary, 
		enemigo: Dictionary, camino_jugador: Dictionary, camino_enemigo: Dictionary):

	setIds(partida, jugador, enemigo, juego, level_data, camino_jugador, camino_enemigo)
	setupData(level_data)
	if Videogame.nivel == VideogameConstants.Nivel.ALEATORIO:
		recreateMap(level_data.map, maze.maze_size.x, maze.maze_size.y, level_data.scale)
	createMap(maze.maze_size.x, maze.maze_size.y)

	if Videogame.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		maze.jugador.setAlgorithm(Videogame.algoritmo_jugador, graph)
	initiate = false
	Videogame.move_enemy = false
	
	var jugador_position = jugador["posicion"].split(",")
	jugador_position = Vector2(int(jugador_position[0]), int(jugador_position[1]))
	initPositions(jugador_position)

	if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		var enemy_position = enemigo["posicion"].split(",")
		enemy_position = Vector2(int(enemy_position[0]), int(enemy_position[1]))
		spawnEnemy(enemy_position)

		var trayectoria = []
		var camino = camino_enemigo["trayectoria"]
		for value in camino:
			var node = value.split(value, ",")
			trayectoria.append(Vector2(int(node[0]), int(node[1])))
		
		maze.enemigo.setPath(maze.enemigo.position, maze.jugador.position, trayectoria)
		if Videogame.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
			trayectoria = []
			camino = camino_jugador["trayectoria"]
			for value in camino:
				var node = value.split(",")
				trayectoria.append(Vector2(int(node[0]), int(node[1])))
				maze.jugador.setPath(maze.enemigo.position, maze.jugador.position, trayectoria)
	else:
		if Videogame.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
			var trayectoria = []
			var camino = camino_jugador["trayectoria"]
			for value in camino:
				var node = value.split(",")
				trayectoria.append(Vector2(int(node[0]), int(node[1])))
				maze.jugador.setPath(maze.enemigo.position, maze.jugador.position, trayectoria)	
			
	game.numero = juego["numero"]

	var resultado = partida["resultado"].split(",")
	win = int(resultado[0])
	lose = int(resultado[1])
	actualizaPuntuacion()
	
	maze.match_state = VideogameConstants.EstadoPartida.EN_CURSO
	game.estado = VideogameConstants.EstadoJuego.EN_CURSO
	game.tiempo_restante = juego["tiempo_restante"]
	timeLabel.text = str(game.tiempo_restante)
	
	if game.estado != 1:
		maze.timer.start(game.tiempo_restante)
		gameProcess()


# Guarda la configuracion modificada
func guardarConfiguracion(modo_interaccion, modo_juego, jugador, enemigo):
	if modo_juego == 0:
		Videogame.modo_juego = VideogameConstants.ModoJuego.MODO_SOLITARIO
	else:
		Videogame.modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO
		
	if modo_interaccion == 0:
		Videogame.modo_interaccion = VideogameConstants.ModoInteraccion.MODO_USUARIO
	else:
		Videogame.modo_interaccion = VideogameConstants.ModoInteraccion.MODO_SIMULACION
	
	if jugador == 0:
		Videogame.algoritmo_jugador = VideogameConstants.Algoritmo.BFS
	elif jugador == 1:
		Videogame.algoritmo_jugador = VideogameConstants.Algoritmo.DFS
	elif jugador == 2:
		Videogame.algoritmo_jugador = VideogameConstants.Algoritmo.DIJKSTRA
	elif jugador == 3:
		Videogame.algoritmo_jugador = VideogameConstants.Algoritmo.A_STAR
	elif jugador == -1:
		Videogame.algoritmo_jugador = VideogameConstants.Algoritmo.EMPTY	
		
	if enemigo == 0:
		Videogame.algoritmo_enemigo = VideogameConstants.Algoritmo.BFS
	elif enemigo == 1:
		Videogame.algoritmo_enemigo = VideogameConstants.Algoritmo.DFS
	elif enemigo == 2:
		Videogame.algoritmo_enemigo = VideogameConstants.Algoritmo.DIJKSTRA
	elif enemigo == 3:
		Videogame.algoritmo_enemigo = VideogameConstants.Algoritmo.A_STAR
	elif enemigo == -1:
		Videogame.algoritmo_enemigo = VideogameConstants.Algoritmo.EMPTY


# Asigna los ids de la partida recuperada para su guardado posterior
func setIds(partida: Dictionary, jugador: Dictionary,  enemigo: Dictionary, juego: Dictionary, nivel: Dictionary, camino_jugador: Dictionary, camino_enemigo: Dictionary):
	Videogame.nombre_partida = partida["nombre"]
	
	ids["id_partida"] = partida["id_partida"]
	ids["id_jugador"] = jugador["id_jugador"]
	ids["id_juego"] = juego["id_juego"]
	ids["id_nivel"] = partida["id_nivel"]

	if camino_jugador.has("id_camino"):
		ids["id_camino_jugador"] = camino_jugador["id_camino"]

	if enemigo.has("id_enemigo"):
		ids["id_enemigo"] = enemigo["id_enemigo"]
		ids["id_camino_enemigo"] = camino_enemigo["id_camino"]



# Recrea el mapa de la cadena de texto almacenada
func recreateMap(maze_map: String, xSize: int, ySize: int, scale_size: Vector2):
	var mapa: Array = [] 
	var pares = maze_map.split(";")
	for par in pares:
		if par != "":
			var coordenadas = par.split(",")
			var x = int(coordenadas[0])
			var y = int(coordenadas[1])
			mapa.append(Vector2(x, y))  
			
	for y in range(2,  ySize/pixels_move + 2):
		for x in range(2,  xSize/pixels_move + 2):
			var node = Vector2(y,x)
			if node not in mapa:
				var atlas_coords = Vector2(0, 0)
				if x == 2 or x == xSize/pixels_move + 1 or y == 2 or y == ySize/pixels_move + 1:
					tilemap.set_cell(0, node, 1, atlas_coords)
				else:
					tilemap.set_cell(0, node, 3, atlas_coords)
	
	for node in mapa:
		var cell = tilemap.local_to_map(node)
		var atlas_coords = Vector2(0, 0)
		tilemap.set_cell(0, cell, 0, atlas_coords)
		
	$"../TextureRect".custom_minimum_size = scale_size


# Recrea el mapa basandose en los id de los tiles del mapa creado
func recreateMaze(maze_map: Dictionary, scale_size: Vector2):
	for node in maze_map:
		var cell = tilemap.local_to_map(node)
		var atlas_coords = Vector2(0, 0)
		tilemap.set_cell(0, cell, maze_map[node], atlas_coords)
		
	

	$"../TextureRect".custom_minimum_size = scale_size
