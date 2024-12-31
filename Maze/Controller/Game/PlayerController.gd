extends CharacterBody2D

class_name PlayerController

const pixels_move = 32
const pixels_center = 16

var player
var enemy
var coin
var maze_finished: bool = false
var is_moving: bool = false
var can_move: bool = false

signal movement_finished


# Inicia los datos del jugador
func _ready():
	player = Player.new()
	player.position = position
	player.actual_position = position
	coin = get_parent().get_node("Moneda")
	player.path = Path.new()


# Fisica del juego, procesa el movimiento hacia una posicion objetivo
# 	- Si el juego, no se ejecuta la fisica de movimiento
# 	- Movimiento hacia una posición (target) siguiendo las fisicas de movimiento
# 	- Comprueba la colision y mantiene la posicion actual
# 	- Estando cerca de la posición objetivo, se corrige la posición final (< 1) y detiene el movimiento
func _process(delta):
	await get_tree().physics_frame

	if maze_finished:
		return

	if player.position != player.target and is_moving:
		player.direction = (player.target - player.position).normalized()
		velocity = player.direction * player.speed
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			updatePosition(player.actual_position)	
			emit_signal("movement_finished")
			velocity = Vector2()	
		elif position.distance_to(player.target) < 1:
			updatePosition(player.target)
			velocity = Vector2()  
				
		if position == player.target:	
			is_moving = false
			emit_signal("movement_finished")


# Registrar movimiento manual en base a las cuatro direcciones (Arriba, Abajo, Derecha, Izquierda) 
#  - Se encuentra en modo Usuario 
#  - Asigna los valores de objetivo y posicion actual
func _input(event: InputEvent):

	if !is_moving and !Singleton.move_enemy and Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_USUARIO: 
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


# Si no se esta moviendo, obtiene el siguiente nodo al que desplazarse
#  	- Se obtiene del camino obtenido mediante la busqueda con los algoritmos
func move():
	if !is_moving:
		is_moving = true
		var node = player.path.trayectoria.pop_front()
		player.actual_position = player.position
		player.target = node


#  - Asigna los valores de objetivo y posicion actual, establece al jugador en movimiento
func asign_values():
	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		if enemy.enemy.path.trayectoria.size() > 0:
			Singleton.move_enemy = true
	is_moving = true
	can_move = false
	player.actual_position = player.position


# Actualiza la posicion cuando ha llegado al objetivo, y lo establece en No movimiento
func updatePosition(new_position: Vector2):
	player.position = new_position
	position = new_position
	is_moving = false


# Asigna el algoritmo de busqueda correspondiente
func setAlgorithm(selected_algorithm: VideogameConstants.Algoritmo, graph: Dictionary):
	player.algorithm = Algorithm.new()
	player.algorithm.algoritmo = selected_algorithm  
	player.algorithm.nombre = VideogameConstants.Algoritmo.keys()[selected_algorithm]
	player.algorithm.graph = graph


# Asigna el camino encontrado mediante el algoritmo de busqueda
func setPath(start_node: Vector2, end_node: Vector2, trayectory: Array):
	player.path.inicio = start_node
	player.path.objetivo = end_node
	player.path.trayectoria = trayectory
