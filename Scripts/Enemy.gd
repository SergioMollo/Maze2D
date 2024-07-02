extends CharacterBody2D

const speed = 150.0
#const JUMP_VELOCITY = -400.0
var maze_finished = false

signal eliminated

@onready var ai_enemy: Node2D = $AIController2DEnemy

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):

	if !maze_finished:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		#velocity = direction * SPEED
		velocity.x = ai_enemy.move.x * speed
		velocity.y = ai_enemy.move.y * speed
		move_and_slide()
		
		
	# Comprobar si el personaje está fuera de los límites del mapa
	#var posicion = global_position
	#if posicion.x < limite_izquierdo:
		#posicion.x = limite_izquierdo

	# Actualizar la posición del personaje
	#global_position = posicion







func _on_node_2d_body_entered(body):
	if body.name == "Personaje":
		emit_signal("eliminated")
