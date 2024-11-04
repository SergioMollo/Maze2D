extends Node2D

# var final = false
var xSize = 10
var ySize = 10
var map = []
var result = []
var graph = {}


@onready var jugador: CharacterBody2D = $Jugador
@onready var agente: Node2D = $Jugador/AIController2D
@onready var moneda: Area2D = $Moneda/Moneda2D
@onready var winLabel : Label  = $CanvasLayer/LabelWin
@onready var loseLabel : Label  = $CanvasLayer/LabelTimeExceed
@onready var infoLabel : Label  = $CanvasLayer/LabelInfo
@onready var timeLabel : Label  = $CanvasLayer/LabelTime
@onready var secondsLabel : Label  = $CanvasLayer/LabelSec
@onready var timer : Timer  = $Timer
@onready var tilemap: Node2D = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().content_scale_size = Vector2i(512, 320)
	#bfs()
	#createMap()
	winLabel.hide()
	loseLabel.hide()
	await get_tree().create_timer(0.0).timeout
	new_game()

func new_game():
	jugador.maze_finished = false
	moneda.show()
	winLabel.hide()
	loseLabel.hide()
	jugador.position = Vector2(48,48)
	timer.start(60)
	#timeLabel.text = str(timer.time_left)
	moneda.coin.connect("collected", mostrarResultado)

# Called every frame. 'delta' is he elapsed time since the previous frame.
func _process(delta):
	if jugador.maze_finished == false:
		timeLabel.text= str(int(timer.time_left))
	
func mostrarResultado():
	jugador.maze_finished = true
	#agente.reward += 10.0
	print("Ha llegado al final del laberinto")
	winLabel.show()
	moneda.hide()
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	new_game()

func _on_timer_timeout():
	jugador.maze_finished = true
	print("Se ha excedido el tiempo")
	loseLabel.show()
	#agente.reward -= 1.0
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	new_game()



# Para los algoritmos

func createMap():
	#map = {
			#0: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			#1: [1, 0, 0, 1, 1, 0, 0, 0, 1, 1],
			#2: [1, 1, 0, 0, 0, 0, 1, 0, 0, 1],
			#3: [1, 0, 0, 1, 1, 0, 1, 0, 1, 1], 
			#4: [1, 0, 1, 0, 1, 1, 1, 0, 0, 1],  
			#5: [1, 0, 1, 0, 0, 0, 0, 1, 0, 1],  
			#6: [1, 0, 0, 0, 1, 1, 0, 0, 1, 1],  
			#7: [1, 0, 1, 1, 0, 0, 1, 0, 1, 1],  
			#8: [1, 0, 0, 0, 0, 1, 1, 0, 2, 1],  
			#9: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	#}
	
	map = [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 0, 0, 1, 1, 0, 0, 0, 1, 1],
		[1, 1, 0, 0, 0, 0, 1, 0, 0, 1],
		[1, 0, 0, 1, 1, 0, 1, 0, 1, 1], 
		[1, 0, 1, 0, 1, 1, 1, 0, 0, 1],  
		[1, 0, 1, 0, 0, 0, 0, 1, 0, 1],  
		[1, 0, 0, 0, 1, 1, 0, 0, 1, 1],  
		[1, 0, 1, 1, 0, 0, 1, 0, 1, 1],  
		[1, 0, 0, 0, 0, 1, 1, 0, 0, 1],  
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	]
	createGraph(map)

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
			if neighbor == 88:
				visited[neighbor] = true
				print("Completo BFS")
				return true
			if neighbor not in visited:
				queue.append(neighbor)
				visited[neighbor] = true
				
				
	#print(queue)

func get_neighbors(node):
	print(node, "->", graph[node])
	# Por ejemplo, si tienes un nodo con una lista de nodos adyacentes:
	return graph[node]








func dfsMaze(start_node, end_node):
	var visited = {}
	recursiveDFS(start_node, end_node, visited)
	print("Resultado: " , result)
	jugador.result = result
			


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
				print("Acumulado: " , result)
				return true
				
	return false
	
	

func createGraph(maze):
	var index = 0
	var childs = []
	for i in range(xSize):
		for j in range(ySize):
			if maze[i][j] != 1:
				
				# Comprobacion de los limites
				
				if i == 0 and j == 0:
					if maze[i][j+1] == 0:
						childs.append(i*ySize + j+1)
					if maze[i+1][j] == 0:
						childs.append((i+1)*ySize + j)	
						
				elif i == xSize-1 and j == ySize-1:
					if maze[i][j-1] == 0:
						childs.append(i*ySize + j-1)
					if maze[i-1][j] == 0:
						childs.append((i-1)*ySize + j)				
							
				elif i == xSize-1 and j == 0:
					if maze[i][j+1] == 0:
						childs.append(i*ySize + j+1)
					if maze[i-1][j] == 0:
						childs.append((i-1)*ySize + j)
						
				elif i == 0 and j == ySize-1:
					if maze[i][j-1] == 0:
						childs.append(i*ySize + j-1)
					if maze[i+1][j] == 0:
						childs.append((i+1)*ySize + j)	
						
				# Comprobacion del interior		
						
				elif i == 0:
					if maze[i][j-1] == 0:
						childs.append(i*ySize + j-1)
					if maze[i][j+1] == 0:
						childs.append(i*ySize + j+1)
					if maze[i+1][j] == 0:
						childs.append((i+1)*ySize + j)	
						
				elif j == 0:
					if maze[i-1][j] == 0:
						childs.append((i-1)*ySize + j)					
					if maze[i][j+1] == 0:
						childs.append(i*ySize + j+1)
					if maze[i+1][j] == 0:
						childs.append((i+1)*ySize + j)	
						
				elif j == ySize-1:
					if maze[i-1][j] == 0:
						childs.append((i-1)*ySize + j)
					if maze[i][j-1] == 0:
						childs.append(i*ySize + j-1)
					if maze[i+1][j] == 0:
						childs.append((i+1)*ySize + j)	
						
				elif i == xSize-1:
					if maze[i-1][j] == 0:
						childs.append((i-1)*ySize + j)
					if maze[i][j-1] == 0:
						childs.append(i*ySize + j-1)
					if maze[i][j+1] == 0:
						childs.append(i*ySize + j+1)

						
				else:
					if maze[i-1][j] == 0:
						childs.append((i-1)*ySize + j)					
					if maze[i][j-1] == 0:
						childs.append(i*ySize + j-1)
					if maze[i][j+1] == 0:
						childs.append(i*ySize + j+1)
					if maze[i+1][j] == 0:
						childs.append((i+1)*ySize + j)		
						
				graph[index] = childs
				childs = []
			index += 1
	
	print(graph)
	bfsMaze(11)
	dfsMaze(11, 88)


#for i in range(xSize):
	#for j in range(ySize):
		#if maze[i][j] != 1:
			#var index = i * ySize + j
			#var childs = []
#
			## Verificar vecinos en todas las direcciones
			#var directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
			#for dir in directions:
				#var ni = i + dir[0]
				#var nj = j + dir[1]
				#if ni >= 0 and ni < xSize and nj >= 0 and nj < ySize and maze[ni][nj] == 0:
					#childs.append(ni * ySize + nj)
#
			#graph[index] = childs



func bfs():
	for i in range(xSize):
		for j in range(ySize):
			if is_wall(Vector2(i*32, j*32)):
				map.append(0)
			else:
				map.append(1)
				
	print(map)

func is_wall(position: Vector2) -> bool:
	print(position)
	# Convierte la posición del mundo a coordenadas del TileMap
	var cell = tilemap.local_to_map(position)
	
	# Obtén el ID del tile en esa celda
	var tile_id = tilemap.get_cell_source_id(0, cell)

	if tile_id == -1:
		return false  # No hay tile en esta celda
	
	# Obtén el TileSet asociado al TileMap
	var tileset = tilemap.tile_set
	
	print("Count: ", tileset.get_source_id())
	
	var physics_layers_count = tileset.get_physics_layers_count()
	for layer_index in range(physics_layers_count):
		var layerPys = tileset.get_physics_layer_collision_layer(layer_index)
		print("Phys: ", layerPys)
		if  layerPys != 0:
			print("Cocacola")  # El tile tiene colisión
	return false  # El tile no tiene colisión
