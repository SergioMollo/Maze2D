extends CharacterBody2D

class_name EnemyController

var enemy
var maze_finished = false
var player

signal eliminated
signal movement_finished

@onready var ai_enemy: Node2D = $AIController2DEnemy


# Inicia los datos del enemigo
func _ready():
	enemy = Enemy.new()
	enemy.position = position
	enemy.actual_position = position
	player = get_parent().get_node("Jugador")
	enemy.path = Path.new()
	

# Fisica del juego, procesa el movimiento hacia una posicion objetivo
# 	- Si el juego, no se ejecuta la fisica de movimiento
# 	- Movimiento hacia una posición (target) siguiendo las fisicas de movimiento
# 	- Comprueba la colision y mantiene la posicion actual
# 	- Estando cerca de la posición objetivo, se corrige la posición final (< 1) y detiene el movimiento
func _process(delta):
	await get_tree().physics_frame

	if !maze_finished and Singleton.move_enemy and enemy.position != enemy.target:

		enemy.direction = (enemy.target - enemy.position).normalized()
		velocity = enemy.direction * enemy.speed
		var collision = move_and_collide(velocity * delta)
		if collision:

			if collision.get_collider() != null and collision.get_collider().name == "Jugador":
				emit_signal("eliminated")
			else:
				updatePosition(enemy.actual_position)
				velocity = Vector2()
		elif position.distance_to(enemy.target) < 1:
			updatePosition(enemy.target)
			velocity = Vector2() 

		if position == enemy.target:
			emit_signal("movement_finished")
			Singleton.move_enemy = false


# Actualiza la posicion cuando ha llegado al objetivo, y lo establece en No movimiento
func updatePosition(new_position: Vector2):
	enemy.position = new_position
	position = new_position


# Si no se esta moviendo, obtiene el siguiente nodo al que desplazarse
#  	- Se obtiene del camino obtenido mediante la busqueda con los algoritmos
func move():
	if !Singleton.move_enemy:
		Singleton.move_enemy = true
		var node = enemy.path.trayectoria.pop_front()	
		enemy.actual_position = enemy.position
		enemy.target = node


# Asigna el algoritmo de busqueda correspondiente
func setAlgorithm(selected_algorithm: VideogameConstants.Algoritmo, graph: Dictionary):
	enemy.algorithm = Algorithm.new()
	enemy.algorithm.algoritmo = selected_algorithm  
	enemy.algorithm.nombre = VideogameConstants.Algoritmo.keys()[selected_algorithm]
	enemy.algorithm.graph = graph


# Asigna el camino encontrado mediante el algoritmo de busqueda
func setPath(start_node: Vector2, end_node: Vector2, trayectory: Array):
	enemy.path.inicio = start_node
	enemy.path.objetivo = end_node
	enemy.path.trayectoria = trayectory
