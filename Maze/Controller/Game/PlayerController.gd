extends CharacterBody2D

class_name PlayerController

const pixels_move = 32
const pixels_center = 16

var player
var enemy
var coin
var coin_position
var maze_finished: bool = false

var path: Path
var algorithm: Algorithm

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.new()
	player.position = position
	player.actual_position = position
	coin = get_parent().get_node("Moneda/Moneda2D")
	path = Path.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	await get_tree().physics_frame

	# Ha finalizado el juego y no se ejecuta la fisica de movimiento
	if maze_finished:
		return

	# Movimiento hacia una posición (target) siguiendo las fisicas de movimiento
	if player.position != player.target and Singleton.move_player:
		player.direction = (player.target - player.position).normalized()
		velocity = player.direction * player.speed
		var collision = move_and_collide(velocity * delta)
		# Comprueba la colision y mantiene la posicion actual
		if collision:
			updatePosition(player.actual_position)	
			velocity = Vector2()
			
		# Estando cerca de la posición objetivo, se corrige la posición final
		elif position.distance_to(player.target) < 1:
			updatePosition(player.target)
			velocity = Vector2()  
		
		# Llegado a la posicion objetivo, se busca de nuevo evitando al enemigo
		if position == player.target:
			newSearch()
			Singleton.move_player = false


# Registrar movimiento manual 
func _input(event: InputEvent):

	if !Singleton.move_player and !Singleton.move_enemy and Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_USUARIO: 
		if event.is_action_pressed("ui_right"):
			player.target = Vector2(player.position.x + pixels_move, player.position.y)
			asign_values()	
		
		elif event.is_action_pressed("ui_left"):
			player.target = Vector2(player.position.x - pixels_move, player.position.y)
			asign_values()
					
		elif event.is_action_pressed("ui_up"):
			player.target = Vector2(player.position.x, player.position.y - pixels_move)
			asign_values()
			
		elif event.is_action_pressed("ui_down"):
			player.target = Vector2(player.position.x, player.position.y + pixels_move)
			asign_values()


# 
func move():
	var node = path.trayectoria[0]
	if !Singleton.move_player:
		Singleton.move_player = true
		path.trayectoria.erase(node)
		player.actual_position = player.position
		player.target = node


# 
func asign_values():
	Singleton.move_player = true
	player.actual_position = player.position
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		enemy.move()


# Asigna el algoritmo correspondiente
func setAlgorithm(selected_algorithm: VideogameConstants.Algoritmo):
	algorithm = Algorithm.new()
	algorithm.algoritmo = selected_algorithm  
	algorithm.nombre = VideogameConstants.Algoritmo.keys()[selected_algorithm]


# 
func updatePosition(new_position: Vector2):
	player.position = new_position
	position = new_position
	Singleton.move_player = false


# 
func newSearch():
	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_COMPUTADORA:				
		if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
			searchCoinWithEnemy(algorithm.graph, player.position, coin_position)


# 
func searchCoin(graph: Dictionary, start_node: Vector2, end_node: Vector2):
	var heuristic = algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y, Vector2(0,0))
	var trayectory = algorithm.search(graph, heuristic, start_node, end_node)
	path.inicio = start_node
	path.objetivo = end_node
	path.trayectoria = trayectory


# 
func searchCoinWithEnemy(graph: Dictionary, start_node: Vector2, end_node: Vector2):
	var heuristic = algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y, enemy.position)
	var trayectory = algorithm.search(graph, heuristic, start_node, end_node)
	path.inicio = start_node
	path.objetivo = end_node
	path.trayectoria = trayectory
