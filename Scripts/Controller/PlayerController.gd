extends CharacterBody2D

class_name PlayerController

const pixels_move = 32
const pixels_center = 16

var player
var coin_controller
var maze_finished: bool = false

var modo_juego : VideogameConstants.ModoJuego

var graph = {}
var result = []

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
func _input(event):

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


func createMap(x_size: int, y_size:int):
	var tilemap = get_parent().get_node("TileMap")
	var map = []
	
	for i in range(16, x_size, pixels_move):
		var row = []
		for j in range(16, y_size, pixels_move):
			var cell = tilemap.local_to_map(Vector2(j, i))
			var id = tilemap.get_cell_source_id(0, cell)
			row.append(id)
		map.append(row)
	createGraph(map, x_size, y_size)

func createGraph(map, xSize, ySize):

	var index
	var childs = []
	for i in range(1, xSize/pixels_move - 1):
		for j in range(1, ySize/pixels_move - 1):
			if map[i][j] == 0:
				if map[i][j-1] == 0:
					childs.append(Vector2(pixels_center + pixels_move*i, pixels_center + pixels_move*(j-1)))
				if map[i][j+1] == 0:
					childs.append(Vector2(pixels_center + pixels_move*i, pixels_center + pixels_move*(j+1)))
				if map[i-1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*(i-1), pixels_center + pixels_move*j))					
				if map[i+1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*(i+1), pixels_center + pixels_move*j))

				graph[Vector2(pixels_center + pixels_move*i, pixels_center + pixels_move*j)] = childs
				childs = []
	
	bfsMaze(player.position)
	# dfsMaze(11, 88)


func bfsMaze(start_node):
	var queue = []
	var visited = {}
	
	# Agregar el nodo inicial a la cola y marcarlo como visitado
	queue.append(start_node)
	visited[start_node] = true
	
	while queue:
		# Sacar un nodo de la cola
		var current_node = queue.pop_front()
		
		# Iterar sobre los nodos adyacentes al nodo actual
		for neighbor in get_neighbors(current_node):
			# Si el vecino no ha sido visitado, marcarlo como visitado y agregarlo a la cola
			if neighbor == Vector2(272,272):
				visited[neighbor] = true
				print("Completo BFS")
				return true
			if neighbor not in visited:
				queue.append(neighbor)
				visited[neighbor] = true


func get_neighbors(node):
	#print(node, "->", graph[node])
	# Un nodo con una lista de nodos adyacentes:
	return graph[node]


func dfsMaze(start_node, end_node):
	var visited = {}
	recursiveDFS(start_node, end_node, visited)


func recursiveDFS(start, end, visited):
	
	# Comprueba si ya se ha visitado
	if start not in visited:
		visited[start] = true
		
		#Comprueba si ha llegado al objetivo
		if start == end:
			print("Completo DFS")	
			return true
			
		#Para cada hijo del nodo se realiza la busqueda recursiva
		for neighbor in get_neighbors(start):
			if recursiveDFS(neighbor, end, visited):
				result.push_front(neighbor)
				return true
				
	return false
