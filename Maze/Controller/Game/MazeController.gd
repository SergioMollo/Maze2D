extends Node2D

class_name MazeController

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

var maze

var game_number = 0
var win = 0
var lose = 0

var match_state: VideogameConstants.EstadoPartida
var game_state: VideogameConstants.EstadoJuego
var initiate: bool = false
 
var map = []
var graph = {}
var ids = {}

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

# 
func _ready():
	await get_tree().create_timer(0.5).timeout


# 
func setup(level_data : Dictionary):
	maze = Maze.new()
	maze.initialize_data(level_data, player, coin, timer, tilemap)
	maze.moneda.coin.connect("collected", mostrarResultado)
	get_window().content_scale_size = maze.scale
	header.size.x = maze.scale.x
	
	createMap(maze.maze_size.x, maze.maze_size.y)

	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		maze.player.setAlgorithm(Singleton.algoritmo_jugador, graph)
		
	winLabel.hide()
	loseLabel.hide()
	maze.moneda.show()
	

# 
func initConfigs(pos: Vector2):
	Singleton.move_player = false
	Singleton.move_enemy = false
	maze.player.position = pos	
	maze.player.player.position = pos	
	maze.player.player.target = pos
	maze.player.player.actual_position = pos

	
# 
func initGame(level_data : Dictionary):
	setup(level_data)
	new_game()

		
# 
func reloadGame(level_data : Dictionary, jugador: Dictionary, enemigo: Dictionary, juego: Dictionary,
		camino_jugador: Dictionary, camino_enemigo: Dictionary):

	# setIDs(jugador[0], enemigo[0], juego[0], nivel[0], camino_jugador[0], camino_enemigo[0])		
	
	setup(level_data)
	initiate = false
	Singleton.move_player = false
	Singleton.move_enemy = false
	
	var jugador_position = Vector2(jugador["posicion_x"], jugador["posicion_y"])
	initConfigs(jugador_position)

	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		var enemy_position = Vector2(enemigo["posicion_x"], enemigo["posicion_y"])
		spawnEnemy(enemy_position)
		var trayectoria = []
		var camino = camino_enemigo["trayectoria"]
		for value in camino:
			var node = value.split(",")
			trayectoria.append(Vector2(int(node[0]), int(node[1])))
		
		maze.enemy.setPath(maze.enemy.position, maze.player.position, trayectoria)
		#maze.enemy.searchPlayer(graph, maze.enemy.position, maze.player.position)
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
		
	
		
	maze.player.maze_finished = false
	maze.timer.start(juego["tiempo_restante"])
	game_number = juego["numero"]
	
	win = level_data["win_games"]
	lose = level_data["lose_games"]
	updatePuntuation()
	
	match_state = VideogameConstants.EstadoPartida.EN_CURSO
	game_state = VideogameConstants.EstadoJuego.EN_CURSO
	timeLabel.text = str(timer.time_left)

	initiate = true


# 
func new_game():
	initiate = false
	await get_tree().create_timer(2.0).timeout
	
	winLabel.hide()
	loseLabel.hide()
	maze.moneda.show()
	game_number += 1
	
	initConfigs(maze.initial_player_position)

	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		spawnEnemy(maze.initial_enemy_position)
		maze.enemy.searchPlayer(maze.enemy.position, maze.player.position)	
		
	maze.player.maze_finished = false
	maze.timer.start(300)
	timeLabel.text = str(timer.time_left)

	initiate = true

# Called every frame. 'delta' is he elapsed time since the previous frame.
func _process(delta):
	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION and !Singleton.move_player and !Singleton.move_enemy and initiate:
		maze.player.move()
		if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
			maze.enemy.move()
	if !maze.player.maze_finished:
		timeLabel.text= str(int(maze.timer.time_left))
	

# Crea un enemigo y lo situa en la posicion concreta
func spawnEnemy(enemy_position: Vector2):
	maze.enemy = enemy_scene.instantiate()
	maze.enemy.position = enemy_position
	maze.enemy.connect("eliminated", mostrarEliminado)
	maze.player.enemy = maze.enemy
	maze.enemy.maze_finished = false
	get_parent().add_child(maze.enemy)
	maze.enemy.setAlgorithm(Singleton.algoritmo_enemigo, graph)


# 
func mostrarResultado():
	initiate = false
	maze.player.maze_finished = true
	win += 1
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		maze.enemy.maze_finished = true
		maze.enemy.queue_free() 
	# agente.reward += 10.0
	# enemigoAgente.reward -= 10.0
	winLabel.position = Vector2(maze.scale.x/2-125,maze.scale.y/2-75)
	winLabel.show()
	maze.moneda.hide()
	await get_tree().create_timer(5.0).timeout
	# agente.reset()
	# enemigoAgente.reset()
	updatePuntuation()
	if game_number < Singleton.juegos:
		new_game()
	else:
		finishLabel.position = Vector2(maze.scale.x/2-170,maze.scale.y-60)
		finishLabel.show()


# 
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
	# agente.reward -= 5.0
	# enemigoAgente.reward += 10.0
	await get_tree().create_timer(5.0).timeout
	# agente.reset()
	# enemigoAgente.reset()
	updatePuntuation()
	if game_number < Singleton.juegos:
		new_game()
	else:
		finishLabel.position = Vector2(maze.scale.x/2-170,maze.scale.y-60)
		finishLabel.show()


# 
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
	# agente.reward -= 1.0
	# enemigoAgente.reward += 2.0
	await get_tree().create_timer(5.0).timeout
	# agente.reset()
	# enemigoAgente.reset()
	updatePuntuation()
	if game_number < Singleton.juegos:
		new_game()
	else:
		finishLabel.position = Vector2(maze.scale.x/2-170,maze.scale.y-60)
		finishLabel.show()
		

#
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



func saveGame(nombre: String):
	
	var partida: Dictionary = {
		"nombre": nombre,
		"estado": match_state,
		"resultado": str(win) + "," + str(lose),
		"numero_juegos": Singleton.juegos,
		"dificultad": Singleton.dificultad,
		"modo_juego": Singleton.modo_juego,
		"modo_interaccion": Singleton.modo_interaccion,
	}


	var mapa: String = ""
	for i in graph:
		var node = tilemap.local_to_map(i)
		mapa += "(" + str(node.x) + "," + str(node.y) + ")" + ";"

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
			trayectoria += "(" + str(node.x) + "," + str(node.y) + ")" + ";"
		
		camino_enemigo = {
			"inicio": str(maze.enemy.position.x) + "," + str(maze.enemy.position.y),
			"objetivo": str(maze.player.position.x) + "," + str(maze.player.position.y),
			"trayectoria": trayectoria
		}
	
	var juego: Dictionary = {
		"numero": game_number,
		"estado": game_state,
		"tiempo_restante": int(maze.timer.time_left),
	}
	
	
	var camino_jugador: Dictionary
	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		var trayectoria: String = ""
		for node in maze.player.path.trayectoria:
			trayectoria += "(" + str(node.x) + "," + str(node.y) + ")" + ";"
		
		camino_jugador = {
			"inicio": str(maze.player.position.x) + "," + str(maze.player.position.y),
			"objetivo": str(maze.coin.position.x) + "," + str(maze.coin.position.y),
			"trayectoria": trayectoria
		}

	Singleton.saveGame(partida, nivel, jugador, enemigo, juego, camino_jugador, camino_enemigo, ids)
