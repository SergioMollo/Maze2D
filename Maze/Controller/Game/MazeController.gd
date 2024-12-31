extends Node2D

class_name MazeController

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

var maze

var game_number = 0
var win = 0
var lose = 0
var time_left = 0

var match_state: VideogameConstants.EstadoPartida
var game_state: VideogameConstants.EstadoJuego
var initiate: bool = false
 
var map = []
var graph = {}
var ids = {
	"id_partida": -1
}

@export var enemy_scene: PackedScene

@onready var player: CharacterBody2D = $"../Jugador"
@onready var agente: Node2D = $"../Jugador/AIController2D"
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
	await get_tree().create_timer(0.5).timeout


# Asigna los valores de configuración (posiciones iniciales, tamaños, tiempo...) al modelo del laberinto
func setup(level_data : Dictionary):
	winLabel.hide()
	loseLabel.hide()
	
	maze = Maze.new()
	maze.initialize_data(level_data, player, coin, timer, tilemap)
	maze.moneda.hide()
	maze.moneda.coin.connect("collected", mostrarResultado)
	
	get_window().content_scale_size = maze.scale
	header.size.x = maze.scale.x
	
	if Singleton.nivel == VideogameConstants.Nivel.ALEATORIO:
		recreateMaze(level_data.map, level_data.scale)
	createMap(maze.maze_size.x, maze.maze_size.y)

	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		maze.player.setAlgorithm(Singleton.algoritmo_jugador, graph)
	

# Inicia las posiciones de los elementos
func initConfigs(pos: Vector2):
	Singleton.move_player = false
	Singleton.move_enemy = false
	maze.player.position = pos	
	maze.player.player.position = pos	
	maze.player.player.target = pos
	maze.player.player.actual_position = pos
	maze.moneda.position = maze.initial_coin_position


# Inicia los datos de configuracion, y en su defecto, recrea el mapa de tiles
func initGame(level_data : Dictionary):
	setup(level_data)
	new_game()

		
# Crea un nuevo juego, asignando las configuraciones iniciales
# 	- Inicia las posiciones de los personajes
# 	- Oculta los mensajes irrelevantes
#  	- Genera el enemigo en el Modo Enfrentamiento
#  	- Inicia el contador de tiempo
func new_game():
	initiate = false
	timeLabel.text = str(maze.time)
	await get_tree().create_timer(5.0).timeout

	winLabel.hide()
	loseLabel.hide()
	game_number += 1
	
	initConfigs(maze.initial_player_position)

	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		spawnEnemy(maze.initial_enemy_position)
	maze.player.maze_finished = false
	
	if game_state != 1:
		maze.timer.start(maze.time)
		game_process()


# Procesa las fisicas del juego, se ejecuta continuamente
# 	- Actualiza el contador de tiempo
func _process(delta):
	if initiate:
		while maze.timer.time_left > 0:
			timeLabel.text = str(int(maze.timer.time_left))
			await get_tree().create_timer(1.0).timeout 
	

#  Proceso del juego, determina el modo de juego, y crea los caminos en casa de requerrirlo
func game_process():
	initiate = true
	maze.moneda.show()
	
	var algorithm = AlgorithmController.new()
	algorithm.graph = graph
	var heuristic = {}
	var trayectory = []
	var scene = get_tree().get_current_scene()

	# maze.timer.stop()

	# Crear heuristica
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		heuristic = algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y, maze.enemy.position)
		algorithm.setEnemyHeuristic(heuristic)

	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		heuristic = algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y)
		algorithm.setPlayerHeuristic(heuristic)

	maze.player.can_move = true

	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_USUARIO and Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_SOLITARIO:
		return

	elif Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_USUARIO and Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		await searchPath(algorithm, trayectory, scene)

		while initiate:
			if maze.enemy.enemy.path.trayectoria.size() > 0:
				await moveOneStep(algorithm)
				Singleton.move_enemy = false
				if Singleton.algoritmo_enemigo == VideogameConstants.Algoritmo.DIJKSTRA or Singleton.algoritmo_enemigo == VideogameConstants.Algoritmo.A_STAR:
					var path_enemigo = await newSearch(Singleton.algoritmo_enemigo ,algorithm, heuristic, maze.enemy.position, maze.player.position, maze.initial_coin_position)
					if !path_enemigo.is_empty():
						await maze.enemy.setPath(maze.enemy.position, maze.player.position, path_enemigo)
			else:
				Singleton.move_enemy = false
				break

	# Para DFS y BFS con y sin enemigo
	elif Singleton.algoritmo_jugador == VideogameConstants.Algoritmo.BFS or Singleton.algoritmo_jugador == VideogameConstants.Algoritmo.DFS:
		await searchPath(algorithm, trayectory, scene)

		while initiate:	
			if maze.enemy.enemy.path.trayectoria.size() > 0:
				await moveOneStep(algorithm)
				if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
					var path_enemigo = await newSearch(Singleton.algoritmo_enemigo ,algorithm, heuristic, maze.enemy.position, maze.player.position, maze.initial_coin_position)
					if !path_enemigo.is_empty():
						await maze.enemy.setPath(maze.enemy.position, maze.player.position, path_enemigo)
			else:
				Singleton.move_enemy = false
				break	
	# Para DFS y BFS con enemigo y modo interaccion
	elif Singleton.algoritmo_enemigo == VideogameConstants.Algoritmo.BFS or Singleton.algoritmo_enemigo == VideogameConstants.Algoritmo.DFS:		
		await searchPath(algorithm, trayectory, scene)

		algorithm.setValueIsPlayer(true)

		while initiate:	
			if maze.enemy.enemy.path.trayectoria.size() > 0:
				await moveOneStep(algorithm)
				var path_jugador = await newSearch(Singleton.algoritmo_jugador,algorithm , heuristic, maze.player.position, maze.initial_coin_position, maze.enemy.position)
				if !path_jugador.is_empty():
					await maze.player.setPath(maze.player.position, maze.initial_coin_position, path_jugador)
			else:
				Singleton.move_enemy = false
				break		

	else:
		while initiate:
			await searchPath(algorithm, trayectory, scene)
			await moveOneStep(algorithm) 

			if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
				heuristic = algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y, maze.enemy.position)
				algorithm.setEnemyHeuristic(heuristic)

			heuristic = algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y)
			algorithm.setPlayerHeuristic(heuristic)


# Busqueda del camino/trayectoria que conecta dos elementos
func searchPath(algorithm: AlgorithmController, trayectory: Array, scene):
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		trayectory = await algorithm.search(maze.player.position, maze.initial_coin_position, tilemap, scene, maze.enemy.position)
		await maze.enemy.setPath(maze.player.position, maze.initial_coin_position, trayectory[1])
	else:
		trayectory = await algorithm.search(maze.player.position, maze.initial_coin_position, tilemap, scene)
		
	await maze.player.setPath(maze.player.position, maze.initial_coin_position, trayectory[0])


# Repite la busqueda del camino/trayectoria que conecta dos elementos cuando el algoritmo es A Estrella o Dijkstra
func newSearch(algorithm_type: VideogameConstants.Algoritmo ,algorithm: AlgorithmController, heuristic: Dictionary, start_node: Vector2, end_node: Vector2, heuristic_position: Vector2):

	var path = []
	if algorithm_type == VideogameConstants.Algoritmo.DIJKSTRA:
		heuristic = algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y, heuristic_position)
		algorithm.setPlayerHeuristic(heuristic)
		path = await algorithm.dijkstraSearch(start_node, end_node)
	
	elif algorithm_type == VideogameConstants.Algoritmo.A_STAR:
		heuristic = algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y, heuristic_position)
		algorithm.setPlayerHeuristic(heuristic)
		path = await algorithm.aStarSearch(start_node, end_node, algorithm.heuristic_player)

	return path


# Mueve un nodo cada personaje, esperando a completar el movimiento
# 	- Borra los tiles que ha recorrido cada personaje
func moveOneStep(algorithm: AlgorithmController):
	# maze.timer.start()

	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		if maze.enemy.enemy.path.trayectoria.size() > 0:
			maze.enemy.move()
			await maze.enemy.movement_finished	
			algorithm.setTilesPath([], maze.enemy.enemy.path.trayectoria)
			await maze.player.movement_finished
	if maze.player.player.path.trayectoria.size() > 0:
		maze.player.move()
		algorithm.setTilesPath(maze.player.player.path.trayectoria, [])
		await maze.player.movement_finished
		


# Inicia el temporizador desde un valor determinado
func continueTimer(time: int):
	maze.timer.start(time)


# Detiene y almacena el valor del temporizador en ese instante
func stopTimer():
	time_left = int(maze.timer.time_left)
	maze.timer.stop()
	

# Crea un enemigo y lo situa en la posicion concreta
func spawnEnemy(enemy_position: Vector2):
	maze.enemy = enemy_scene.instantiate()
	maze.enemy.position = enemy_position
	maze.enemy.connect("eliminated", mostrarEliminado)
	maze.player.enemy = maze.enemy
	maze.enemy.maze_finished = false
	get_parent().add_child(maze.enemy)
	maze.enemy.setAlgorithm(Singleton.algoritmo_enemigo, graph)


# Muestra el resultado de victoria
# 	- Aumenta en 1 el numero de victorias del jugador y actualiza la puntuacion
#  	- Elimina al enemigo
# 	- Espera 5 segundos hasta iniciar el siguiente juego
func mostrarResultado():
	initiate = false
	win += 1
	maze.timer.stop()

	winLabel.position = Vector2(maze.scale.x/2-125,maze.scale.y/2-75)
	winLabel.show()
	maze.moneda.hide()
	updatePuntuation()
	await get_tree().create_timer(2.0).timeout
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		maze.enemy.maze_finished = true
		maze.enemy.queue_free() 
	maze.player.maze_finished = true
	await get_tree().create_timer(3.0).timeout

	if game_number < Singleton.juegos:
		new_game()
	else:
		finishLabel.position = Vector2(maze.scale.x/2-170,maze.scale.y-60)
		finishLabel.show()


# Muestra el resultado de derrota por alcance del enemigo
# 	- Aumenta en 1 el numero de victorias del enemigo y actualiza la puntuacion
#  	- Elimina al enemigo
# 	- Espera 5 segundos hasta iniciar el siguiente juego
func mostrarEliminado():
	initiate = false
	maze.timer.stop()
	maze.player.maze_finished = true
	maze.enemy.maze_finished = true

	lose += 1
	loseLabel.position = Vector2(maze.scale.x/2-125,maze.scale.y/2-75)
	loseLabel.show()

	maze.enemy.queue_free() 
	maze.moneda.hide()
	updatePuntuation()
	await get_tree().create_timer(5.0).timeout

	if game_number < Singleton.juegos:
		new_game()
	else:
		finishLabel.position = Vector2(maze.scale.x/2-170,maze.scale.y-60)
		finishLabel.show()


# Muestra el resultado de derrota por exceso de tiempo
# 	- Aumenta en 1 el numero de victorias del enemigo/computadora y actualiza la puntuacion
#  	- Elimina al enemigo
# 	- Espera 5 segundos hasta iniciar el siguiente juego
func _on_timer_timeout():
	initiate = false
	maze.timer.stop()
	maze.player.maze_finished = true
	lose += 1

	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		maze.enemy.maze_finished = true
		maze.enemy.queue_free()

	timeExceedLabel.position = Vector2(maze.scale.x/2-125,maze.scale.y/2-75)
	loseLabel.show()
	updatePuntuation()
	await get_tree().create_timer(5.0).timeout

	if game_number < Singleton.juegos:
		new_game()
	else:
		finishLabel.position = Vector2(maze.scale.x/2-170,maze.scale.y-60)
		finishLabel.show()
		

# Actualiza la etiqueta de puntuacion de la cabecera
func updatePuntuation():
	var puntuation : Label  = $"../Layer/Header/Layer/Panel/Container/Result/Results/LabelResultado"	
	puntuation.text = str(win) + "-" + str(lose)


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
func saveGame(nombre: String):
	
	var partida: Dictionary = {
		"nombre": nombre,
		"estado": match_state,
		"resultado": str(win) + "," + str(lose),
		"numero_juegos": Singleton.juegos,
		"dificultad": Singleton.dificultad,
		"modo_juego": Singleton.modo_juego,
		"modo_interaccion": Singleton.modo_interaccion,
		"fecha": Time.get_date_string_from_system()
	}

	var mapa: String = ""
	for i in graph:
		var node = tilemap.local_to_map(i)
		mapa += str(node.x) + "," + str(node.y) + ";"

	var nivel: Dictionary = {
		"nivel": Singleton.nivel,
		"maze_size": str(maze.maze_size.x) + "," + str(maze.maze_size.y),
		"scale": str(maze.scale.x) + "," + str(maze.scale.y),
		"initial_player_position": str(maze.initial_player_position.x) + "," + str(maze.initial_player_position.y),
		"initial_enemy_position": str(maze.initial_enemy_position.x) + "," + str(maze.initial_enemy_position.y),
		"initial_coin_position": str(maze.initial_coin_position.x) + "," + str(maze.initial_coin_position.y),
		"map": mapa
	}
	
	var jugador: Dictionary = {
		"posicion": str(maze.player.position.x) + "," +  str(maze.player.position.y),
		"algoritmo": Singleton.algoritmo_jugador,
		"apariencia": Singleton.player_texture,
	}
	
	var enemigo: Dictionary = {}
	var camino_enemigo: Dictionary = {}
	if maze.enemy != null:
		enemigo = {
			"posicion": str(maze.enemy.position.x) + "," +  str(maze.enemy.position.y),
			"algoritmo": Singleton.algoritmo_enemigo,
			"apariencia": Singleton.enemy_texture,
		}
		
		var trayectoria: String = ""
		for node in maze.enemy.path.trayectoria:
			trayectoria += str(node.x) + "," + str(node.y) + ";"
		
		camino_enemigo = {
			"inicio": str(maze.enemy.position.x) + "," + str(maze.enemy.position.y),
			"objetivo": str(maze.player.position.x) + "," + str(maze.player.position.y),
			"trayectoria": trayectoria
		}
	
	var juego: Dictionary = {
		"numero": game_number,
		"estado": game_state,
		"tiempo_restante": int(time_left),
	}
	
	
	var camino_jugador: Dictionary
	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		var trayectoria: String = ""
		for node in maze.player.path.trayectoria:
			trayectoria += str(node.x) + "," + str(node.y) + ";"
		
		camino_jugador = {
			"inicio": str(maze.player.position.x) + "," + str(maze.player.position.y),
			"objetivo": str(maze.coin.position.x) + "," + str(maze.coin.position.y),
			"trayectoria": trayectoria
		}

	Singleton.saveGame(partida, nivel, jugador, enemigo, juego, camino_jugador, camino_enemigo, ids)


# Recupera los datos de la partida cargada y establece la configuración y progreso obtenido
func reloadGame(partida : Dictionary, jugador: Dictionary, juego: Dictionary, level_data: Dictionary, 
		enemigo: Dictionary, camino_jugador: Dictionary, camino_enemigo: Dictionary):

	setIds(partida, jugador, enemigo, juego, level_data, camino_jugador, camino_enemigo)		

	setup(level_data)
	initiate = false
	Singleton.move_player = false
	Singleton.move_enemy = false
	
	var jugador_position = jugador["posicion"].split(",")
	jugador_position = Vector2(int(jugador_position[0]), int(jugador_position[1]))
	initConfigs(jugador_position)

	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		var enemy_position = enemigo["posicion"].split(",")
		enemy_position = Vector2(int(enemy_position[0]), int(enemy_position[1]))
		spawnEnemy(enemy_position)

		var trayectoria = []
		var camino = camino_enemigo["trayectoria"]
		for value in camino:
			var node = value.split(value, ",")
			trayectoria.append(Vector2(int(node[0]), int(node[1])))
		
		maze.enemy.setPath(maze.enemy.position, maze.player.position, trayectoria)
		if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
			trayectoria = []
			camino = camino_jugador["trayectoria"]
			for value in camino:
				var node = value.split(",")
				trayectoria.append(Vector2(int(node[0]), int(node[1])))
				maze.player.setPath(maze.enemy.position, maze.player.position, trayectoria)
	else:
		if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
			var trayectoria = []
			var camino = camino_jugador["trayectoria"]
			for value in camino:
				var node = value.split(",")
				trayectoria.append(Vector2(int(node[0]), int(node[1])))
				maze.player.setPath(maze.enemy.position, maze.player.position, trayectoria)	
			
	game_number = juego["numero"]

	var resultado = partida["resultado"].split(",")
	win = int(resultado[0])
	lose = int(resultado[1])
	updatePuntuation()
	
	match_state = VideogameConstants.EstadoPartida.EN_CURSO
	game_state = VideogameConstants.EstadoJuego.EN_CURSO
	time_left = juego["tiempo_restante"]
	timeLabel.text = str(time_left)
	
	if game_state != 1:
		maze.timer.start(time_left)
		game_process()


# Asigna los ids de la partida recuperada para su guardado posterior
func setIds(partida: Dictionary, jugador: Dictionary,  enemigo: Dictionary, juego: Dictionary, nivel: Dictionary, camino_jugador: Dictionary, camino_enemigo: Dictionary):
	Singleton.nombre_partida = partida["nombre"]
	
	ids["id_partida"] = partida["id_partida"]
	ids["id_jugador"] = jugador["id_jugador"]
	ids["id_juego"] = juego["id_juego"]
	ids["id_nivel"] = partida["id_nivel"]

	if camino_jugador.has("id_camino"):
		ids["id_camino_jugador"] = camino_jugador["id_camino"]

	if enemigo.has("id_enemigo"):
		ids["id_enemigo"] = enemigo["id_enemigo"]
		ids["id_camino_enemigo"] = camino_enemigo["id_camino"]


# Recrea el mapa basandose en los id de los tiles del mapa creado
func recreateMaze(maze_map: Dictionary, scale_size: Vector2):
	for node in maze_map:
		var cell = tilemap.local_to_map(node)
		var atlas_coords = Vector2i(0, 0)
		tilemap.set_cell(0, cell, maze_map[node], atlas_coords)

	$"../TextureRect".custom_minimum_size = scale_size
