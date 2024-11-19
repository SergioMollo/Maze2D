extends  CharacterBody2D

class_name EnemyController

var enemy
var maze_finished = false
var player_controller
signal eliminated



@onready var ai_enemy: Node2D = $AIController2DEnemy


func _ready():
	enemy = Enemy.new()
	enemy.position = position
	enemy.actual_position = position
	player_controller = get_parent().get_node("Jugador")
	
func _process(delta):
	await get_tree().physics_frame

	if !maze_finished and player_controller.player.moving and enemy.position != enemy.target:

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
				enemy.moving = false
				velocity = Vector2()
				
			# Si estamos muy cerca de la posición objetivo, corregimos la posición final
		elif position.distance_to(enemy.target) < 1:
			enemy.position = enemy.target
			position = enemy.target
			velocity = Vector2()  # Detenemos el movimiento
			enemy.moving = false

		if position == enemy.target:
			enemy.moving = false



func _input(event):

	if !enemy.moving:
		if event.is_action_pressed("ui_right"):
			enemy.moving = true
			enemy.actual_position = enemy.position
			enemy.target.x = enemy.position.x + 32
			enemy.target.y = enemy.position.y		
			
		elif event.is_action_pressed("ui_left"):
			enemy.moving = true
			enemy.actual_position = enemy.position
			enemy.target.x = enemy.position.x - 32
			enemy.target.y = enemy.position.y
			
		elif event.is_action_pressed("ui_up"):
			enemy.moving = true
			enemy.actual_position = enemy.position
			enemy.target.x = enemy.position.x 
			enemy.target.y = enemy.position.y - 32
			
		elif event.is_action_pressed("ui_down"):
			enemy.moving = true
			enemy.actual_position = enemy.position
			enemy.target.x = enemy.position.x
			enemy.target.y = enemy.position.y + 32
