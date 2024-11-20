extends CharacterBody2D

class_name PlayerController

const pixels_move = 32
const pixels_center = 16

var player
var enemy
var coin_controller
var maze_finished: bool = false

var path = []

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
		if player.position != player.target and Singleton.move_player:
			player.direction = (player.target - player.position).normalized()
			velocity = player.direction * player.speed
			var collision = move_and_collide(velocity * delta)

			# Comprobacion de que ha habido colision mantener posicion actual
			if collision:
				player.position = player.actual_position
				position = player.actual_position
				Singleton.move_player = false
				velocity = Vector2()
				
			# Si estamos muy cerca de la posición objetivo, corregimos la posición final
			elif position.distance_to(player.target) < 1:
				player.position = player.target
				position = player.target
				velocity = Vector2()  # Detenemos el movimiento
				Singleton.move_player = false

			if position == player.target:
				Singleton.move_player = false


# Registrar movimiento manual 
func _input(event: InputEvent):

	if !Singleton.move_player and !Singleton.move_enemy and Singleton.modo_juego == VideogameConstants.ModoInteraccion.MODO_USUARIO: 
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
func asign_values():
		Singleton.move_player = true
		player.actual_position = player.position
		if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
			enemy.move()


# Asigna el algoritmo correspondiente
func setAlgorithm(selected_algorithm: VideogameConstants.Algoritmo):
	var algorithm = Algorithm.new()
	algorithm.algoritmo = selected_algorithm  
	algorithm.nombre = VideogameConstants.Algoritmo.keys()[selected_algorithm]


# 
func searchCoin(graph: Dictionary, heuristic: Dictionary, start_node: Vector2, end_node: Vector2):
	self.algoritmo.search(graph, heuristic, start_node, end_node)


# 
func searchCoinWithEnemy(graph: Dictionary, heuristic: Dictionary, start_node: Vector2, end_node: Vector2):
	self.algoritmo.search(graph, heuristic, start_node, end_node)

