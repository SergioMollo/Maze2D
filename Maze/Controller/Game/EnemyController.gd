extends CharacterBody2D

class_name EnemyController

var enemy
var maze_finished = false
var player
# var is_moving: bool = false

signal eliminated
signal movement_finished


@onready var ai_enemy: Node2D = $AIController2DEnemy


# 
func _ready():
	enemy = Enemy.new()
	enemy.position = position
	enemy.actual_position = position
	player = get_parent().get_node("Jugador")
	enemy.path = Path.new()
	

# 
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
				
		# Si estamos muy cerca de la posición objetivo, corregimos la posición final
		elif position.distance_to(enemy.target) < 1:
			updatePosition(enemy.target)
			velocity = Vector2()  # Detenemos el movimiento

		if position == enemy.target:
			emit_signal("movement_finished")
			Singleton.move_enemy = false


# 
func updatePosition(new_position: Vector2):
	enemy.position = new_position
	position = new_position


# 
func move():
	if !Singleton.move_enemy:
		Singleton.move_enemy = true
		var node = enemy.path.trayectoria.pop_front()	
		enemy.actual_position = enemy.position
		enemy.target = node



# Asigna el algoritmo correspondiente
func setAlgorithm(selected_algorithm: VideogameConstants.Algoritmo, graph: Dictionary):
	enemy.algorithm = Algorithm.new()
	enemy.algorithm.algoritmo = selected_algorithm  
	enemy.algorithm.nombre = VideogameConstants.Algoritmo.keys()[selected_algorithm]
	enemy.algorithm.graph = graph




#
func setPath(start_node: Vector2, end_node: Vector2, trayectory: Array):
	enemy.path.inicio = start_node
	enemy.path.objetivo = end_node
	enemy.path.trayectoria = trayectory

	

# 
func searchPlayer(start_node: Vector2, end_node: Vector2):
	var heuristic = enemy.algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y, player.position)
	var scene = get_tree().get_current_scene()
	var tilemap = scene.get_node("./TileMap")
	var trayectory = await enemy.algorithm.search(heuristic, start_node, end_node, tilemap, scene, false)
	setPath(start_node, end_node, trayectory)
