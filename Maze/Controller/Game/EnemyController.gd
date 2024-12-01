extends  CharacterBody2D

class_name EnemyController

var enemy
var maze_finished = false
var player
signal eliminated

var path: Path
var algorithm: Algorithm

@onready var ai_enemy: Node2D = $AIController2DEnemy


func _ready():
	enemy = Enemy.new()
	enemy.position = position
	enemy.actual_position = position
	player = get_parent().get_node("Jugador")
	path = Path.new()
	
func _process(delta):
	await get_tree().physics_frame

	if !maze_finished and Singleton.move_enemy and enemy.position != enemy.target:

		# var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		# velocity = direction * SPEED
		# enemy.direction = ai_enemy.move.normalized()
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
			newSearch()
			Singleton.move_enemy = false


# 
func updatePosition(new_position: Vector2):
	enemy.position = new_position
	position = new_position


# 
func newSearch():
	searchPlayer(enemy.position, player.position)


# 
func move():
	var node = path.trayectoria[0]
	if !Singleton.move_enemy:
		Singleton.move_enemy = true
		enemy.actual_position = enemy.position
		enemy.target = node
		path.trayectoria.erase(node)


# Asigna el algoritmo correspondiente
func setAlgorithm(selected_algorithm: VideogameConstants.Algoritmo, graph: Dictionary):
	algorithm = Algorithm.new()
	algorithm.algoritmo = selected_algorithm  
	algorithm.nombre = VideogameConstants.Algoritmo.keys()[selected_algorithm]
	algorithm.graph = graph


#
func setPath(start_node: Vector2, end_node: Vector2, trayectory: Array):
	path.inicio = start_node
	path.objetivo = end_node
	path.trayectoria = trayectory

	

# 
func searchPlayer(start_node: Vector2, end_node: Vector2):
	var heuristic = algorithm.createHeuristic(Singleton.maze_size.x, Singleton.maze_size.y, player.position)
	var trayectory = algorithm.search(heuristic, start_node, end_node)
	setPath(start_node, end_node, trayectory)
