extends CharacterBody2D

class_name EnemyController

var enemy
var player

var maze_finished = false

signal eliminated
signal movement_finished


# Inicia los datos del enemigo
func _ready():
	enemy = Enemy.new()
	enemy.position = position
	enemy.actual_position = position
	player = get_parent().get_node("Jugador")

# Fisica del juego, procesa el movimiento hacia una posicion objetivo
# 	- Si el juego, no se ejecuta la fisica de movimiento
# 	- Movimiento hacia una posición (target) siguiendo las fisicas de movimiento
# 	- Comprueba la colision y mantiene la posicion actual
# 	- Estando cerca de la posición objetivo, se corrige la posición final (< 1) y detiene el movimiento
func _process(delta):
	await get_tree().physics_frame

	if !maze_finished and Videogame.move_enemy and enemy.position != enemy.target:

		enemy.direction = (enemy.target - enemy.position).normalized()
		velocity = enemy.direction * enemy.speed
		var collision = move_and_collide(velocity * delta)

		if collision:

			if collision.get_collider() != null and collision.get_collider().name == "Jugador":
				emit_signal("eliminated")
			else:
				actualizaPosicion(enemy.actual_position)
				velocity = Vector2()
				
		elif position.distance_to(enemy.target) < 1:
			actualizaPosicion(enemy.target)
			velocity = Vector2() 

		if position == enemy.target:
			emit_signal("movement_finished")
			Videogame.move_enemy = false


# Actualiza la posicion cuando ha llegado al objetivo, y lo establece en No movimiento
func actualizaPosicion(new_position: Vector2):
	enemy.position = new_position
	position = new_position
	force_update_transform()
	

# Si no se esta moviendo, obtiene el siguiente nodo al que desplazarse
#  	- Se obtiene del camino obtenido mediante la busqueda con los algoritmos
func desplazarse():
	if !Videogame.move_enemy:
		Videogame.move_enemy = true
		var node = enemy.path.trayectoria.pop_front()	
		enemy.actual_position = enemy.position
		enemy.target = node


# Asigna el algoritmo de busqueda correspondiente
func setAlgorithm(selected_algorithm: VideogameConstants.Algoritmo, graph: Dictionary):
	enemy.algorithm = Algorithm.new(selected_algorithm, Videogame.getAlgoritmoString(selected_algorithm), graph)


# Asigna el camino encontrado mediante el algoritmo de busqueda
func setPath(start_node: Vector2, end_node: Vector2, trayectory: Array):
	enemy.path = Path.new(start_node, end_node, trayectory)
