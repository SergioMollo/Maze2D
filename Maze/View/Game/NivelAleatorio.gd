extends  Node2D

class_name Aleatorio

@onready var maze_controller: Node2D = $Maze

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

const min_size = 15
const max_size = 40

var level_data = {
	"maze_size": Vector2i(0,0),
	"scale": Vector2i(0, 0),
	"initial_player_position": Vector2(0,0),
	"initial_enemy_position": Vector2(0,0),
	"initial_coin_position": Vector2(0,0),
	"time": 150
}


func _ready():	
	pass
	
	
# Genera aleatoriamente valores para el tamaño del laberinto y las posiciones de los personajes y elementos
# 	- Tamaño del laberinto entre: 15x15 y 40x40
# 	- Posicion personajes: Dentro de los limites del laberinto y sin posiciones repetidas
func createGame():

	var size_y = randi_range(min_size, max_size)
	var size_x = randi_range(size_y, max_size)
	var map = {}
	var pos_player = Vector2(0,0)
	var pos_coin = Vector2(0,0)
	var pos_enemy = Vector2(0,0)
	var pixels_init = pixels_center + pixels_offset

	level_data.maze_size = Vector2i(size_x*pixels_move, size_y*pixels_move)
	level_data.scale = Vector2i(size_x*pixels_move + 128, size_y*pixels_move + 128)
	pos_player = Vector2(randi_range(1, size_x-2) * pixels_move + pixels_init, randi_range(1, size_y-2) * pixels_move + pixels_init)
	pos_coin = Vector2(randi_range(1, size_x-2) * pixels_move + pixels_init, randi_range(1, size_y-2) * pixels_move + pixels_init)

	if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		pos_enemy = Vector2(randi_range(1, size_x-2) * pixels_move + pixels_init, randi_range(1, size_y-2) * pixels_move + pixels_init)
	
	while pos_coin == pos_player:
		pos_coin = Vector2(randi_range(1, size_x-2) * pixels_move + pixels_init, randi_range(1, size_y-2) * pixels_move + pixels_init)
		
	while pos_coin == pos_enemy or pos_enemy == pos_player:
		pos_enemy = Vector2(randi_range(1, size_x-2) * pixels_move + pixels_init, randi_range(1, size_y-2) * pixels_move + pixels_init)

	map = await generateAleatoryMap(pos_player, pos_coin, pos_enemy, size_x, size_y)	
	level_data.initial_player_position = pos_player
	level_data.initial_coin_position = pos_coin
	level_data.initial_enemy_position = pos_enemy
	level_data.map = map
	maze_controller.initGame(level_data)


# Asigna los valores de la partida cargada
# 	- Carga la partida con la configuracion recuperada
func asignValues(partida: Dictionary, jugador: Dictionary, juego: Dictionary, nivel: Dictionary, 
	enemigo: Dictionary = {}, camino_jugador: Dictionary = {}, camino_enemigo: Dictionary = {}):

	for key in level_data.keys():
		if nivel.has(key):
			level_data[key] = nivel[key]
		
	maze_controller.continuarPartida(partida, jugador, juego, level_data, enemigo, camino_jugador, camino_enemigo)


# Genera un mapa aleatorio asegurando la conexion entre el jugador y la moneda, y el jugador y el enemigo (en su defecto)
# 	- Realiza la busqueda en profundidad para conectarlos
# 	- Genera muros y cesped aleatorios en nodos que no se encuentran en las conexiones generadas
func generateAleatoryMap(pos_player: Vector2, pos_coin: Vector2, pos_enemy: Vector2, size_x: int, size_y: int):
	var graph = {}
	var maze_map = []
	var map = {}
	var values = [0, 2]
	var conexion_coin = []
	var conexion_enemy = []
	var algorithm = AlgorithmController.new()
	algorithm.is_player = false

	for y in size_y:
		var row = []	
		for x in size_x:
			var id = 0
			var pos = Vector2(x*pixels_move + pixels_center + pixels_offset, y*pixels_move + pixels_center + pixels_offset)
			if x == 0 or x == size_x - 1 or y == 0 or y == size_y - 1:	
				id = 1			
			row.append(id)
			graph[pos] = id
		maze_map.append(row)

	map = createMap(size_x, size_y, maze_map)
	algorithm.graph = map
	conexion_coin = await algorithm.dfsSearch(pos_player, pos_coin)
	if Videogame.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		conexion_enemy = await algorithm.dfsSearch(pos_player, pos_enemy)

	for node in graph:
		if node not in conexion_coin and node not in conexion_enemy and graph[node] != 1 and node != pos_player and node != pos_coin and node != pos_enemy:
			var id = values[randi() % values.size()]
			graph[node] = id

	return graph
	

# Crea el grafo que se utilizara para obtener las trayectorias de cada camino
# 	- Asigna los nodos anexos a cada nodo en los que puede realizar movimiento
#	- Para que este aleatoriamente ordenado y la busqueda en profundidad sea más dispar utiliza shuffle()
func createMap(xSize: int, ySize: int, map: Array):
	var graph = {}
	var childs = []
	for i in range(1,  ySize- 1):
		for j in range(1, xSize - 1):
			if map[i][j] == 0:
				if map[i][j+1] == 0:
					childs.append(Vector2(pixels_center + pixels_move*(j+1) + pixels_offset, pixels_center + pixels_move*i + pixels_offset))
				if map[i+1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*j + pixels_offset, pixels_center + pixels_move*(i+1) + pixels_offset))
				if map[i-1][j] == 0:
					childs.append(Vector2(pixels_center + pixels_move*j + pixels_offset, pixels_center + pixels_move*(i-1) + pixels_offset))	
				if map[i][j-1] == 0:
					childs.append(Vector2(pixels_center + pixels_move*(j-1) + pixels_offset, pixels_center + pixels_move*i + pixels_offset))	

				childs.shuffle() 
				graph[Vector2(pixels_center + pixels_move*j + pixels_offset, pixels_center + pixels_move*i + pixels_offset)] = childs
				childs = []

	return graph
