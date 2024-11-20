extends  CharacterBody2D

class_name EnemyController

var enemy
var maze_finished = false
var player
signal eliminated

var path = []

@onready var ai_enemy: Node2D = $AIController2DEnemy


func _ready():
	enemy = Enemy.new()
	enemy.position = position
	enemy.actual_position = position
	player = get_parent().get_node("Jugador")
	
func _process(delta):
	await get_tree().physics_frame

	if !maze_finished and Singleton.move_enemy and enemy.position != enemy.target:

		# var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		# velocity = direction * SPEED
		# enemy.direction = ai_enemy.move.normalized()
		enemy.direction = (enemy.target - enemy.position).normalized()
		velocity = enemy.direction * enemy.speed
		# move_and_slide()
		var collision = move_and_collide(velocity * delta)

		if collision:

			if collision.get_collider() != null and collision.get_collider().name == "Jugador":
				emit_signal("eliminated")
			else:
				enemy.position = enemy.actual_position
				position = enemy.actual_position
				Singleton.move_enemy = false
				velocity = Vector2()
				
		# Si estamos muy cerca de la posición objetivo, corregimos la posición final
		elif position.distance_to(enemy.target) < 1:
			enemy.position = enemy.target
			position = enemy.target
			velocity = Vector2()  # Detenemos el movimiento
			Singleton.move_enemy = false

		if position == enemy.target:
			Singleton.move_enemy = false



func move():
	var node = path[0]
	if !Singleton.move_enemy:
		Singleton.move_enemy = true
		enemy.actual_position = enemy.position
		enemy.target = node
		path.erase(node)


# Asigna el algoritmo correspondiente
func setAlgorithm(selected_algorithm: VideogameConstants.Algoritmo):

	var algorithm = Algorithm.new()
	algorithm.algoritmo = selected_algorithm  
	algorithm.nombre = VideogameConstants.Algoritmo.keys()[selected_algorithm]


# 
func searchPlayer(graph: Dictionary, heuristic: Dictionary, start_node: Vector2, end_node: Vector2):
	self.algoritmo.search(graph, heuristic, start_node, end_node)
