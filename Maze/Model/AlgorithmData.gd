extends Node

class_name Algorithm

var nombre: String
var algoritmo: VideogameConstants.Algoritmo
var descripcion: String

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

var graph = {}
var heuristic = {}
var resultdfs = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func search(calcuated_graph: Dictionary, calcuated_heuristic: Dictionary, start_node: Vector2, end_node: Vector2):
	graph = calcuated_graph
	heuristic = calcuated_heuristic
	var path = []

	if algoritmo == VideogameConstants.Algoritmo.BFS:
		path = bfsMaze(start_node, end_node)
	elif algoritmo == VideogameConstants.Algoritmo.DFS:
		dfsMaze(start_node, end_node)
		path = resultdfs
	elif algoritmo == VideogameConstants.Algoritmo.DIJKSTRA:
		path = dijkstraMaze(start_node, end_node)
	elif algoritmo == VideogameConstants.Algoritmo.A_STAR:
		path = aStarMaze(start_node, end_node)

	return path


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
		if heuristic_position != Vector2(0,0):
			var calculated_heuristic = max_heuristic - (abs(heuristic_position.x - node.x) + abs(heuristic_position.y - node.y))/32
			if calculated_heuristic > initial_heuristic:
				heuristic[node] = calculated_heuristic

	return heuristic


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


# 
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


# 
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
