extends CharacterBody2D

class_name PlayerController

const pixels_move = 32
const pixels_center = 16

var player
var coin_controller
var maze_finished: bool = false

var modo_juego : VideogameConstants.ModoJuego

var graph = {}
var heuristic = {}
var resultdfs = []
# var resultbfs = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.new()
	player.position = position
	player.actual_position = position
	coin_controller = get_parent().get_node("Moneda/Moneda2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	await get_tree().physics_frame

	# No ha finalizado el juego
	if !maze_finished:

		# Se requiere un moviemiento a una posicion distinta a la actual
		if player.position != player.target and player.moving:
			player.direction = (player.target - player.position).normalized()
			velocity = player.direction * player.speed
			var collision = move_and_collide(velocity * delta)

			# Comprobacion de que ha habido colision mantener posicion actual
			if collision:
				player.position = player.actual_position
				position = player.actual_position
				player.moving = false
				velocity = Vector2()
				
			# Si estamos muy cerca de la posición objetivo, corregimos la posición final
			elif position.distance_to(player.target) < 1:
				player.position = player.target
				position = player.target
				velocity = Vector2()  # Detenemos el movimiento
				player.moving = false

			if position == player.target:
				player.moving = false


#### Registrar movimiento manual 
func _input(event: InputEvent):

	if !player.moving:
		if event.is_action_pressed("ui_right"):
			player.moving = true
			player.actual_position = player.position
			player.target.x = player.position.x + pixels_move
			player.target.y = player.position.y		
			
		elif event.is_action_pressed("ui_left"):
			player.moving = true
			player.actual_position = player.position
			player.target.x = player.position.x - pixels_move
			player.target.y = player.position.y
			
		elif event.is_action_pressed("ui_up"):
			player.moving = true
			player.actual_position = player.position
			player.target.x = player.position.x 
			player.target.y = player.position.y - pixels_move
			
		elif event.is_action_pressed("ui_down"):
			player.moving = true
			player.actual_position = player.position
			player.target.x = player.position.x
			player.target.y = player.position.y + pixels_move




# Crea el array con los datos del laberinto (celdas con colision y sin colision)
func createMap(x_size: int, y_size:int):
	var tilemap = get_parent().get_node("TileMap")
	var map = []
	
	for i in range(16, y_size, pixels_move):
		var row = []
		for j in range(16, x_size, pixels_move):
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
					childs.append(Vector2(pixels_center + pixels_move*(j+1), pixels_center + pixels_move*i))
				if map[i+1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*j, pixels_center + pixels_move*(i+1)))
				if map[i][j-1] == 0:
					childs.append(Vector2(pixels_center + pixels_move*(j-1), pixels_center + pixels_move*i))				
				if map[i-1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*j, pixels_center + pixels_move*(i-1)))					
				
				graph[Vector2(pixels_center + pixels_move*j, pixels_center + pixels_move*i)] = childs
				childs = []

# Crea una heuristica en los nodos en funcion de donde esta el enemigo (mayor valor cuanto mas cercano)
func createHeuristic(x_size: int, y_size:int, heuristic_position: Vector2):

	var max_heuristic
	var initial_heuristic = 1

	if x_size > y_size:
		max_heuristic = x_size/64
	else:
		max_heuristic = y_size/64

	for node in graph.keys():
		heuristic[node] = initial_heuristic
		var calculated_heuristic = max_heuristic - (abs(heuristic_position.x - node.x) + abs(heuristic_position.y - node.y))/32
		if calculated_heuristic > initial_heuristic:
			heuristic[node] = calculated_heuristic



# Utiliza el algoritmo primero en anchura (BFS) para encontrar la trayectoria hasta la moneda
func bfsMaze(start_node: Vector2, end_node: Vector2):
	var queue = []
	var visited = {}
	var parent = {}
	
	# Agregar el nodo inicial a la cola y marcarlo como visitado
	queue.append(start_node)
	visited[start_node] = true
	parent[start_node] = null

	while queue:
		# Sacar un nodo de la cola
		var current_node = queue.pop_front()

		if current_node == end_node:
			visited[current_node] = true
			return createPath(start_node, end_node, parent)
		
		# Iterar sobre los nodos adyacentes al nodo actual
		for neighbor in get_neighbors(current_node):
			# Si el vecino no ha sido visitado, marcarlo como visitado y agregarlo a la cola
			if neighbor not in visited:
				queue.append(neighbor)
				visited[neighbor] = true
				parent[neighbor] = current_node



# Utiliza el algoritmo primero en profundidad (DFS) para encontrar la trayectoria hasta la moneda
func dfsMaze(start_node: Vector2, end_node: Vector2):
	var visited = {}
	recursiveDFS(start_node, end_node, visited)
	return resultdfs

# Ejecuta de manera recursiva la busqueda de los hijos de un nodo
func recursiveDFS(start: Vector2, end: Vector2, visited):
	
	# Comprueba si ya se ha visitado
	if start not in visited:
		visited[start] = true
		
		#Comprueba si ha llegado al objetivo
		if start == end:
			return true
				
		#Para cada hijo del nodo se realiza la busqueda recursiva
		for neighbor in get_neighbors(start):
			if recursiveDFS(neighbor, end, visited):
				resultdfs.push_front(neighbor)
				return true
				
	return false

func dijkstraMaze(start_node: Vector2, end_node: Vector2):

	var weigth = 1
	var distances = {}
	var parent = {}
	var queue = []
	
	var asign = asignWeigth(start_node, distances, parent)
	distances = asign[0]
	parent = asign[1]
	queue.append([0, start_node])
		
	while queue:
		queue.sort()
		var node = queue.pop_front()
		var current_distance = node[0]
		var current_node = node[1]
		
		if current_node == end_node:
			return createPath(start_node, end_node, parent)
		
		for neighbor in get_neighbors(current_node):
			var distance = current_distance + weigth
			if distance < distances[neighbor]:
				distances[neighbor] = distance
				parent[neighbor] = current_node
				queue.append([distance, neighbor])
				
	return []			
				
func aStarMaze(start_node: Vector2, end_node: Vector2):

	var weigth = 1
	var distances = {}
	var parent = {}
	var queue = []
	
	var asign = asignWeigth(start_node, distances, parent)
	distances = asign[0]
	parent = asign[1]

	queue.append([0, start_node])
		
	while queue:
		queue.sort()
		var node = queue.pop_front()
		var current_distance = node[0]
		var current_node = node[1]
		
		if current_node == end_node:
			return createPath(start_node, end_node, parent)
		
		for neighbor in get_neighbors(current_node):
			var distance = current_distance + weigth + heuristic[neighbor]
			if distance < distances[neighbor]:
				distances[neighbor] = distance
				parent[neighbor] = current_node
				queue.append([distance, neighbor])
				
	return []	

#  Obtiene la lista de nodos adyacentes al nodo actual que puede realizar el desplazamiento
func get_neighbors(node: Vector2):
	return graph[node]		

func asignWeigth(start_node: Vector2, distances: Dictionary, parent: Dictionary):

	for key in graph.keys():
		distances[key] = 9999999
		parent[key] = null

	distances[start_node] = 0
	
	return [distances, parent]
				
# Reconstruye el camino desde la posicion del jugador hasta la posicion de la moneda 
func createPath(start_node: Vector2, end_node: Vector2, parent: Dictionary):
	var path = []
	var current_node = end_node

	while current_node != start_node:
		path.insert(0, current_node)
		current_node = parent[current_node]

	return path
