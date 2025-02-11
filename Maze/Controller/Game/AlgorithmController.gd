extends Node

class_name AlgorithmController

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

var graph = {}
var heuristic_player = {}
var heuristic_enemy = {}
var penalty = 0
var resultdfs = []
var visited = []

var path_jugador = []
var path_enemigo = []

var tilemap
var scene
var is_player: bool = true


# Inica los datos cuando se instancia por primera vez
func _ready():
	pass


# Realiza la busqueda y recreacion de los caminos entre dos elementos mediante los algoritmos de busqueda de cada personaje
#  	- Comprueba el algoritmo del jugador y busca la moneda aplicando ese algoritmo, luego recrea el camino
#  	- Comprueba el algoritmo del enemigo y busca al jugador aplicando ese algoritmo, luego recrea el camino
#  	- Actualiza el mapa de tiles del laberinto, mostrando los caminos obtenidos
#	- Devuelve los caminos del jugador y del enemigo
func search(jugador_position: Vector2, coin_position: Vector2, tile: TileMap, scene_tree, enemy_position: Vector2 = Vector2(-1,-1)):
	tilemap = tile
	scene = scene_tree

	# Jugador	
	is_player = true
	if Videogame.algoritmo_jugador == VideogameConstants.Algoritmo.BFS:
		path_jugador = await bfsSearch(jugador_position, coin_position)
	elif Videogame.algoritmo_jugador == VideogameConstants.Algoritmo.DFS:
		await dfsSearch(jugador_position, coin_position)
		path_jugador = resultdfs
	elif Videogame.algoritmo_jugador == VideogameConstants.Algoritmo.DIJKSTRA:
		path_jugador = await dijkstraSearch(jugador_position, coin_position, enemy_position)
	elif Videogame.algoritmo_jugador == VideogameConstants.Algoritmo.A_STAR:
		path_jugador = await aStarSearch(jugador_position, coin_position, heuristic_player, enemy_position)
		
	# Enemigo	
	is_player = false
	if Videogame.algoritmo_enemigo == VideogameConstants.Algoritmo.BFS:
		path_enemigo = await bfsSearch(enemy_position, jugador_position)
	elif Videogame.algoritmo_enemigo == VideogameConstants.Algoritmo.DFS:
		await dfsSearch(enemy_position, jugador_position)
		path_enemigo = resultdfs
	elif Videogame.algoritmo_enemigo == VideogameConstants.Algoritmo.DIJKSTRA:
		path_enemigo = await dijkstraSearch(enemy_position, jugador_position, coin_position)
	elif Videogame.algoritmo_enemigo == VideogameConstants.Algoritmo.A_STAR:
		path_enemigo = await aStarSearch(enemy_position, jugador_position, heuristic_enemy, coin_position)

	await setTilesPath(path_jugador, path_enemigo)

	return [path_jugador, path_enemigo]


# Crea una heuristica en los nodos en funcion de la posicion en la que se encuentra el objetivo 
#  	- El valor calculado para cada nodo depende de la cercania a la posicion del objetivo
#	- Menor valor cuando más cercania
func createHeuristic(x_size: int, y_size:int, heuristic_position: Vector2 = Vector2(0,0)):
	var heuristic = {}
	penalty = (x_size + y_size) / 10

	for node in graph.keys():
		if heuristic_position != Vector2(0,0):
			heuristic[node] = (abs(heuristic_position.x - node.x) + abs(heuristic_position.y - node.y))/ pixels_move

	return heuristic


# Establece la heuristica del jugador
func setPlayerHeuristic(heuristic: Dictionary):
	heuristic_player = heuristic


# Establece la heuristica del enemigo
func setEnemyHeuristic(heuristic: Dictionary):
	heuristic_enemy = heuristic


# Utiliza el algoritmo primero en anchura (BFS) para encontrar la trayectoria hasta el objetivo
# 	- Agregar el nodo inicial a la cola y marcarlo como visitado
# 	- Saca un nodo de la cola e itera sobre los nodos adyacentes al nodo actual
# 	- Si el vecino no ha sido visitado, lo marca como visitado y lo agrega a la cola
func bfsSearch(start_node: Vector2, end_node: Vector2):
	var queue = []
	var parent = {}
	visited = []

	queue.append(start_node)
	visited.append(start_node)
	parent[start_node] = null

	while queue:
		var current_node = queue.pop_front()
		visited.append(current_node)
		if current_node == end_node:
			await printSearchTiles()
			return await createPath(start_node, end_node, parent)
		
		for neighbor in get_neighbors(current_node):	
			if neighbor not in visited:
				queue.append(neighbor)
				parent[neighbor] = current_node


# Utiliza el algoritmo primero en profundidad (DFS) para encontrar la trayectoria hasta el objetivo
# 	- Itera recursivamente en la busqueda de los nodos hijos
func dfsSearch(start_node: Vector2, end_node: Vector2):
	visited = []
	recursiveDFS(start_node, end_node)
	await printSearchTiles()
	return resultdfs


# Ejecuta de manera recursiva la busqueda de los hijos de un nodo
# 	- Comprueba si el nodo ya se ha visitado, en su defecto, comprueba si ha llegado al objetivo
# 	- Para cada hijo del nodo se realiza la busqueda recursiva de sus hijos
func recursiveDFS(start: Vector2, end: Vector2):
	if start not in visited:
		visited.append(start)	
		if start == end:
			return true
				
		for neighbor in get_neighbors(start):
			if recursiveDFS(neighbor, end):
				resultdfs.push_front(neighbor)
				return true
				
	return false


# Utiliza el algoritmo Dijkstra para encontrar la trayectoria hasta el objetivo
# 	- Agregar el nodo inicial a la cola y marcarlo como visitado
# 	- Saca un nodo de la cola, ordena la lista e itera sobre los nodos adyacentes al nodo actual
# 	- Si el vecino no ha sido visitado, lo marca como visitado y lo agrega a la cola
#	- Comprueba el peso y distancia desde un nodo hasta el hijo
# 	- Actualiza la distancia acumulada en caso de ser menor
func dijkstraSearch(start_node: Vector2, end_node: Vector2, avoid_position: Vector2):
	var distances = {}
	var parent = {}
	var heap = []
	visited = []

	var asign = inicializeNodesWeigth(start_node, distances, parent)
	distances = asign[0]
	parent = asign[1]

	heap.append([0, start_node])
	visited.append(start_node)
		
	while heap:
		var node = popHeap(heap)
		var accumulated_cost = node[0]
		var current_node = node[1]
		visited.append(current_node)
		
		if current_node == end_node:
			await printSearchTiles()
			return await createPath(start_node, end_node, parent)
		
		for neighbor in get_neighbors(current_node):
			var cost = getCost(neighbor, avoid_position)
			var new_cost = accumulated_cost + cost

			if new_cost < distances[neighbor]:
				distances[neighbor] = new_cost
				parent[neighbor] = current_node
				pushHeap(heap, [new_cost, neighbor])
				
	return []		


# Utiliza el algoritmo Dijkstra para encontrar la trayectoria hasta el objetivo
# 	- Agregar el nodo inicial a la cola y marcarlo como visitado
# 	- Saca un nodo de la cola, ordena la lista e itera sobre los nodos adyacentes al nodo actual
# 	- Si el vecino no ha sido visitado, lo marca como visitado y lo agrega a la cola
# 	- El costo de moverse de un nodo a otro siempre es 1
#	- Comprueba el peso, heuristica del hijo y distancia desde un nodo hasta el hijo
# 	- Actualiza la distancia acumulada en caso de ser menor
func aStarSearch(start_node: Vector2, end_node: Vector2, heuristic: Dictionary, avoid_position: Vector2):
	var distances = {}
	var parent = {}
	var heap = []
	visited = []

	var asign = inicializeNodesWeigth(start_node, distances, parent)
	distances = asign[0]
	parent = asign[1]

	heap.append([0, start_node])
	visited.append(start_node)
		
	while heap:
		var node = popHeap(heap)
		var accumulated_cost = node[0]
		var current_node = node[1]
		visited.append(current_node)
		
		if current_node == end_node:
			await printSearchTiles()
			return await createPath(start_node, end_node, parent)
		
		for neighbor in get_neighbors(current_node):
			var cost = getCost(neighbor, avoid_position)
			var movement_cost = cost + heuristic[neighbor]
			var new_cost = accumulated_cost + movement_cost

			if new_cost < distances[neighbor]:
				distances[neighbor] = new_cost
				parent[neighbor] = current_node
				pushHeap(heap, [new_cost, neighbor])
				
	return []
	

#  Obtiene la lista de nodos adyacentes al nodo actual que puede realizar el desplazamiento
func get_neighbors(node: Vector2):
	return graph[node]	


# Asigna pesos al grafo que se usara para calcular las distancias y pesos en los algoritmos Dijkstra y A Estrella
func inicializeNodesWeigth(start_node: Vector2, distances: Dictionary, parent: Dictionary):

	for key in graph.keys():
		distances[key] = INF
		parent[key] = null

	distances[start_node] = 0
	
	return [distances, parent]


# Obtiene el coste de ir de un nodo a otro teniendo en cuenta la posicion que debe evitar
# 	- Se penaliza cuanto más cerca esté de la posicion a evitar, mayor será el costo
func getCost(next_position: Vector2, avoid_position: Vector2):
	var default_cost = 1
	var distance_to_enemy = abs(avoid_position.x - next_position.x) + abs(avoid_position.y - next_position.y)
	var penalty_cost = max(penalty - distance_to_enemy, default_cost) 

	return default_cost + penalty_cost


# Inserta elementos en la cola de prioridad
func pushHeap(heap, element):
	heap.append(element)
	heap.sort_custom(sortAscending) 


# Ordena elementos de la cola de prioridad de forma ascendente
func sortAscending(a, b): 
	if a[0] < b[0]:
		return true
	return  false


# Obtiene el primer elemento de la cola de prioridad
func popHeap(heap):
	if heap.is_empty():
		return null
	else:
		return heap.pop_front()


# Muestra la sucesion de nodos visitados por el algoritmo en orden
func printSearchTiles():
	var size = visited.size()
	var time_await: float = 1.0/(size*1000000)
	
	for node in visited:
		if is_player:
			var cell = tilemap.local_to_map(node)
			var atlas_coords = Vector2i(0, 0)
			tilemap.set_cell(0, cell, 7, atlas_coords)
			await scene.get_tree().create_timer(time_await).timeout	
	
			
# Reconstruye el camino desde la posicion del jugador hasta la posicion de la moneda 
func createPath(start_node: Vector2, end_node: Vector2, parent: Dictionary):
	var path = []
	var current_node = end_node

	while current_node != start_node:
		path.insert(0, current_node)
		current_node = parent[current_node]

	return path


# Resalta el camino encontrado hacia el objetivo en el mapa de tiles del laberinto
# 	- Muestra el camino del enemigo
# 	- Muestra el camino del jugador
# 	- Reestableblece los tiles que no se encuentran en ambos caminos
func setTilesPath(camino_jugador: Array, camino_enemigo: Array):

	path_jugador = camino_jugador
	path_enemigo = camino_enemigo

	for node in path_enemigo:
		var cell = tilemap.local_to_map(node)
		var atlas_coords = Vector2i(0, 0)
		tilemap.set_cell(0, cell, 4, atlas_coords)

	for node in path_jugador:
		var cell = tilemap.local_to_map(node)
		var atlas_coords = Vector2i(0, 0)
		tilemap.set_cell(0, cell, 8, atlas_coords)

	for node in graph:
		var cell = tilemap.local_to_map(node)
		var atlas_coords = Vector2i(0, 0)
		if node not in path_jugador and node not in path_enemigo:
			tilemap.set_cell(0, cell, 0, atlas_coords)
			


# Establece el valor boleano de is_player
func setValueIsPlayer(value: bool):
	is_player = value
