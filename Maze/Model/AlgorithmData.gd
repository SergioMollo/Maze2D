extends Node

class_name Algorithm

var nombre: String
var algoritmo: VideogameConstants.Algoritmo

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

var graph = {}
var heuristic = {}
var resultdfs = []

var tilemap
var scene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# 
func search(calcuated_heuristic: Dictionary, start_node: Vector2, end_node: Vector2, tile: TileMap, scene_tree, avoid_node: Vector2 = Vector2(-1,-1)):
	tilemap = tile
	scene = scene_tree
	heuristic = calcuated_heuristic
	var path = []
	resultdfs = []

	if algoritmo == VideogameConstants.Algoritmo.BFS:
		path = await bfsSearch(start_node, end_node, avoid_node)
	elif algoritmo == VideogameConstants.Algoritmo.DFS:
		dfsSearch(start_node, end_node, avoid_node)
		path = resultdfs
	elif algoritmo == VideogameConstants.Algoritmo.DIJKSTRA:
		path = await dijkstraSearch(start_node, end_node)
	elif algoritmo == VideogameConstants.Algoritmo.A_STAR:
		path = await aStarSearch(start_node, end_node)

	return path


# Crea una heuristica en los nodos en funcion de donde esta el enemigo (mayor valor cuanto mas cercano)
func createHeuristic(x_size: int, y_size:int, heuristic_position: Vector2 = Vector2(0,0)):
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


# Utiliza el algoritmo primero en anchura (BFS) para encontrar la trayectoria hasta la moneda
func bfsSearch(start_node: Vector2, end_node: Vector2, avoid_node: Vector2):
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
			return await createPath(start_node, end_node, parent)
		
		# Iterar sobre los nodos adyacentes al nodo actual
		for neighbor in get_neighbors(current_node):
			var cell = tilemap.local_to_map(neighbor)
			var atlas_coords = Vector2i(0, 0)
			tilemap.set_cell(0, cell, 7, atlas_coords)
			await scene.get_tree().create_timer(0.025).timeout
			
			# Si el vecino no ha sido visitado, marcarlo como visitado y agregarlo a la cola
			if neighbor not in visited:
				visited[neighbor] = true
				if neighbor != avoid_node:
					queue.append(neighbor)
					parent[neighbor] = current_node


# Utiliza el algoritmo primero en profundidad (DFS) para encontrar la trayectoria hasta la moneda
func dfsSearch(start_node: Vector2, end_node: Vector2, avoid_node: Vector2):
	var visited = {}
	recursiveDFS(start_node, end_node, visited, avoid_node)
	return resultdfs


# Ejecuta de manera recursiva la busqueda de los hijos de un nodo
func recursiveDFS(start: Vector2, end: Vector2, visited: Dictionary, avoid_node: Vector2):

	# Comprueba si ya se ha visitado
	if start not in visited:
		visited[start] = true
		
		#Comprueba si ha llegado al objetivo
		if start == end:
			return true
				
		#Para cada hijo del nodo se realiza la busqueda recursiva
		for neighbor in get_neighbors(start):
			if neighbor != avoid_node:
				if recursiveDFS(neighbor, end, visited, avoid_node):
					resultdfs.push_front(neighbor)
					return true
				
	return false


# 
func dijkstraSearch(start_node: Vector2, end_node: Vector2):

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
			return await createPath(start_node, end_node, parent)
		
		for neighbor in get_neighbors(current_node):			
			var distance = current_distance + weigth
			if distance < distances[neighbor]:
				distances[neighbor] = distance
				parent[neighbor] = current_node
				queue.append([distance, neighbor])
				
	return []			


# 
func aStarSearch(start_node: Vector2, end_node: Vector2):

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
			return await createPath(start_node, end_node, parent)
		
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


# Asigna pesos al grafo
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

	await setTilesPath(path)
	return path


# Resalta el camino encontrado hacia el objetivo
func setTilesPath(path: Array):
	for node in graph:
		var cell = tilemap.local_to_map(node)
		var atlas_coords = Vector2i(0, 0)
		if node in path:
			tilemap.set_cell(0, cell, 8, atlas_coords)
		else:
			tilemap.set_cell(0, cell, 0, atlas_coords)
		await scene.get_tree().create_timer(0.005).timeout
