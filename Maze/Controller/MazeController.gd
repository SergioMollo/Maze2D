extends Node2D

class_name MazeController

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

var maze
var juegos
 
var graph = {}

@export var enemy_scene: PackedScene

@onready var player: CharacterBody2D = $"../Jugador"
@onready var agente: Node2D = $"../Jugador/AIController2D"
@onready var coin: Area2D = $"../Moneda/Moneda2D"
@onready var header = $"../Layer/Header/Layer/Panel"
@onready var winLabel : Label  = $"../Layer/LabelWin"
@onready var loseLabel : Label  = $"../Layer/LabelTimeExceed"
@onready var timeLabel : Label  = $"../Layer/Header/Layer/Panel/Container/Time/ValueTime/LabelTime"
@onready var timer : Timer  = $"../Timer"
@onready var tilemap = $"../TileMap"


# 
func setup(level_data : Dictionary):
	maze = Maze.new()
	maze.initialize_data(level_data, player, coin, timer, tilemap)
	maze.moneda.coin.connect("collected", mostrarResultado)
	get_window().content_scale_size = maze.scale
	header.size.x = maze.scale.x

	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_COMPUTADORA:
		maze.player.setAlgorithm(Singleton.algoritmo)
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		maze.enemy.setAlgorithm(Singleton.algoritmo)
	

# 
func _ready():
	# Se asigna directamente hasta que se implelmente el paso de datos de configuracion inicial
	winLabel.hide()
	loseLabel.hide()
	await get_tree().create_timer(1.0).timeout
	juegos = Singleton.juegos
	new_game()


# 
func new_game():

	juegos -= 1
	maze.moneda.show()
	winLabel.hide()
	loseLabel.hide()
	maze.player.position = maze.initial_player_position	
	maze.player.player.target = maze.initial_player_position
	maze.player.player.actual_position = maze.initial_player_position
	maze.player.maze_finished = false

	createMap(maze.xSize, maze.ySize)

	var player_heuristic = {}
	var enemy_heuristic = {}

	# Provisional hasta configurar datos y pasarlo
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		spawnEnemy()
		player_heuristic = createHeuristic(maze.xSize, maze.ySize, maze.enemy.position)
		enemy_heuristic = createHeuristic(maze.xSize, maze.ySize, maze.coin.position)
		maze.enemy.searchPlayer(graph, enemy_heuristic, maze.enemy.position, maze.player.position)
		if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_COMPUTADORA:
			maze.player.searchCoinWithEnemy(graph, player_heuristic, maze.player.position, maze.enemy.position)
	else:
		if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_COMPUTADORA:
			createHeuristic(maze.xSize, maze.ySize, Vector2(0,0))
			maze.player.searchCoin(graph, player_heuristic, maze.player.position, maze.coin.position)	

	# player.enemy = get_parent().get_node("Enemy")
	# var result_bfs = bfsMaze(maze.enemy.position, maze.player.position)
	# maze.enemy.path = result_bfs
	# var result_dfs = player.dfsMaze(maze.player.position, maze.initial_coin_position)
	# var result_dijkstra = maze.player.dijkstraMaze(maze.player.position, maze.initial_coin_position)
	# var result_a_star = maze.player.aStarMaze(maze.player.position, maze.initial_coin_position)
		
	maze.timer.start(60)
	timeLabel.text = str(timer.time_left)

# Called every frame. 'delta' is he elapsed time since the previous frame.
func _process(delta):
	if maze.player.maze_finished == false:
		timeLabel.text= str(int(maze.timer.time_left))
	

# 
func spawnEnemy():
	maze.enemy = enemy_scene.instantiate()
	maze.enemy.position = maze.initial_enemy_position
	maze.enemy.connect("eliminated", mostrarEliminado)
	maze.enemy.maze_finished = false
	get_parent().add_child(maze.enemy)


# 
func mostrarResultado():
	maze.player.maze_finished = true
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		maze.enemy.maze_finished = true
		maze.enemy.queue_free() 
	# agente.reward += 10.0
	# enemigoAgente.reward -= 10.0
	print("Ha llegado al final del laberinto")
	winLabel.show()
	maze.moneda.hide()
	await get_tree().create_timer(5.0).timeout
	# agente.reset()
	# enemigoAgente.reset()

	if juegos > 0:
		new_game()


# 
func mostrarEliminado():
	maze.player.maze_finished = true
	maze.enemy.maze_finished = true
	print("El enemigo le ha eliminado")
	loseLabel.show()
	maze.enemy.queue_free() 
	# agente.reward -= 5.0
	# enemigoAgente.reward += 10.0
	await get_tree().create_timer(5.0).timeout
	# agente.reset()
	# enemigoAgente.reset()
	if juegos > 0:
		new_game()


# 
func _on_timer_timeout():
	maze.player.maze_finished = true
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		maze.enemy.maze_finished = true
		maze.enemy.queue_free()
	print("Se ha excedido el tiempo")
	loseLabel.show()
	# agente.reward -= 1.0
	# enemigoAgente.reward += 2.0
	await get_tree().create_timer(5.0).timeout
	# agente.reset()
	# enemigoAgente.reset()
	if juegos > 0:
		new_game()


# Crea el array con los datos del laberinto (celdas con colision y sin colision)
func createMap(x_size: int, y_size:int):
	# Dondvar tilemap = get_parent().get_node("TileMap")
	var map = []
	
	for i in range(80, y_size+64, pixels_move):
		var row = []
		for j in range(80, x_size+64, pixels_move):
			var cell = tilemap.local_to_map(Vector2(j, i))
			var id = tilemap.get_cell_source_id(0, cell)
			row.append(id)
		map.append(row)

	createGraph(map, x_size, y_size)


# Crea el grafo que se utilizara para obtener las trayectorias de cada camino
func createGraph(map: Array, xSize: int, ySize: int):

	var childs = []
	for i in range(1, ySize/pixels_move - 1):
		for j in range(1, xSize/pixels_move - 1):
			if map[i][j] == 0:
				if map[i][j+1] == 0:
					childs.append(Vector2(pixels_center + pixels_move*(j+1) + pixels_offset, pixels_center + pixels_move*i + pixels_offset))
				if map[i+1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*j + pixels_offset, pixels_center + pixels_move*(i+1) + pixels_offset))
				if map[i][j-1] == 0:
					childs.append(Vector2(pixels_center + pixels_move*(j-1) + pixels_offset, pixels_center + pixels_move*i + pixels_offset))				
				if map[i-1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*j + pixels_offset, pixels_center + pixels_move*(i-1) + pixels_offset))					
				
				graph[Vector2(pixels_center + pixels_move*j + pixels_offset, pixels_center + pixels_move*i + pixels_offset)] = childs
				childs = []


# Crea una heuristica en los nodos en funcion de donde esta el enemigo (mayor valor cuanto mas cercano)
func createHeuristic(x_size: int, y_size:int, heuristic_position: Vector2):
	var heuristic = {}
	var max_heuristic
	var initial_heuristic = 1

	if x_size > y_size:
		max_heuristic = x_size/64
	else:
		max_heuristic = y_size/64

	for node in graph.keys():
		heuristic[node] = initial_heuristic
		if heuristic_position != Vector2(0,0):
			var calculated_heuristic = max_heuristic - (abs(heuristic_position.x - node.x) + abs(heuristic_position.y - node.y))/32
			if calculated_heuristic > initial_heuristic:
				heuristic[node] = calculated_heuristic

	return heuristic

# # Utiliza el algoritmo primero en anchura (BFS) para encontrar la trayectoria hasta la moneda
# func bfsMaze(start_node: Vector2, end_node: Vector2):
# 	var queue = []
# 	var visited = {}
# 	var parent = {}
	
# 	# Agregar el nodo inicial a la cola y marcarlo como visitado
# 	queue.append(start_node)
# 	visited[start_node] = true
# 	parent[start_node] = null

# 	while queue:
# 		# Sacar un nodo de la cola
# 		var current_node = queue.pop_front()

# 		if current_node == end_node:
# 			visited[current_node] = true
# 			return createPath(start_node, end_node, parent)
		
# 		# Iterar sobre los nodos adyacentes al nodo actual
# 		for neighbor in get_neighbors(current_node):
# 			# Si el vecino no ha sido visitado, marcarlo como visitado y agregarlo a la cola
# 			if neighbor not in visited:
# 				queue.append(neighbor)
# 				visited[neighbor] = true
# 				parent[neighbor] = current_node


# # Utiliza el algoritmo primero en profundidad (DFS) para encontrar la trayectoria hasta la moneda
# func dfsMaze(start_node: Vector2, end_node: Vector2):
# 	var visited = {}
# 	recursiveDFS(start_node, end_node, visited)
# 	return resultdfs


# # Ejecuta de manera recursiva la busqueda de los hijos de un nodo
# func recursiveDFS(start: Vector2, end: Vector2, visited):
	
# 	# Comprueba si ya se ha visitado
# 	if start not in visited:
# 		visited[start] = true
		
# 		#Comprueba si ha llegado al objetivo
# 		if start == end:
# 			return true
				
# 		#Para cada hijo del nodo se realiza la busqueda recursiva
# 		for neighbor in get_neighbors(start):
# 			if recursiveDFS(neighbor, end, visited):
# 				resultdfs.push_front(neighbor)
# 				return true
				
# 	return false


# # 
# func dijkstraMaze(start_node: Vector2, end_node: Vector2):

# 	var weigth = 1
# 	var distances = {}
# 	var parent = {}
# 	var queue = []
	
# 	var asign = asignWeigth(start_node, distances, parent)
# 	distances = asign[0]
# 	parent = asign[1]
# 	queue.append([0, start_node])
		
# 	while queue:
# 		queue.sort()
# 		var node = queue.pop_front()
# 		var current_distance = node[0]
# 		var current_node = node[1]
		
# 		if current_node == end_node:
# 			return createPath(start_node, end_node, parent)
		
# 		for neighbor in get_neighbors(current_node):
# 			var distance = current_distance + weigth
# 			if distance < distances[neighbor]:
# 				distances[neighbor] = distance
# 				parent[neighbor] = current_node
# 				queue.append([distance, neighbor])
				
# 	return []			


# # 
# func aStarMaze(start_node: Vector2, end_node: Vector2):

# 	var weigth = 1
# 	var distances = {}
# 	var parent = {}
# 	var queue = []
	
# 	var asign = asignWeigth(start_node, distances, parent)
# 	distances = asign[0]
# 	parent = asign[1]

# 	queue.append([0, start_node])
		
# 	while queue:
# 		queue.sort()
# 		var node = queue.pop_front()
# 		var current_distance = node[0]
# 		var current_node = node[1]
		
# 		if current_node == end_node:
# 			return createPath(start_node, end_node, parent)
		
# 		for neighbor in get_neighbors(current_node):
# 			var distance = current_distance + weigth + heuristic[neighbor]
# 			if distance < distances[neighbor]:
# 				distances[neighbor] = distance
# 				parent[neighbor] = current_node
# 				queue.append([distance, neighbor])
				
# 	return []	


# #  Obtiene la lista de nodos adyacentes al nodo actual que puede realizar el desplazamiento
# func get_neighbors(node: Vector2):
# 	return graph[node]		

# func asignWeigth(start_node: Vector2, distances: Dictionary, parent: Dictionary):

# 	for key in graph.keys():
# 		distances[key] = 9999999
# 		parent[key] = null

# 	distances[start_node] = 0
	
# 	return [distances, parent]
	
			
# # Reconstruye el camino desde la posicion del jugador hasta la posicion de la moneda 
# func createPath(start_node: Vector2, end_node: Vector2, parent: Dictionary):
# 	var path = []
# 	var current_node = end_node

# 	while current_node != start_node:
# 		path.insert(0, current_node)
# 		current_node = parent[current_node]

# 	return path

