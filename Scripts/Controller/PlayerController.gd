extends CharacterBody2D

class_name PlayerController

var player
var maze_finished: bool = false
# var target = Vector2.ZERO

var modo_juego : VideogameConstants.ModoJuego
var enemy
var instance : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.new()
	player.position = position
	player.actual_position = position

	# print(position)
	# add_child(player)
	# player = get_node("/root/Nivel1/Jugador/Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	await get_tree().physics_frame

	# No ha finalizado el juego
	if !maze_finished:

		# Se requiere un moviemiento a una posicion distinta a la actual
		if player.position != player.target and player.moving:
			player.direction = (player.target - player.position).normalized()
			velocity = player.direction * player.speed
			var collision = move_and_collide(velocity * delta)

			# Comprobacion de que ha habido colision mantener posicion actual
			if collision:
				player.position = player.actual_position
				position = player.actual_position
				player.moving = false
				velocity = Vector2()
				
			# Si estamos muy cerca de la posición objetivo, corregimos la posición final
			elif position.distance_to(player.target) < 1:
				player.position = player.target
				position = player.target
				velocity = Vector2()  # Detenemos el movimiento
				player.moving = false

			if position == player.target:
				player.moving = false


#### Registrar movimiento manual 
func _input(event):

	if !player.moving:
		if event.is_action_pressed("ui_right"):
			player.moving = true
			player.actual_position = player.position
			player.target.x = player.position.x + 32
			player.target.y = player.position.y		
			
		elif event.is_action_pressed("ui_left"):
			player.moving = true
			player.actual_position = player.position
			player.target.x = player.position.x - 32
			player.target.y = player.position.y
			
		elif event.is_action_pressed("ui_up"):
			player.moving = true
			player.actual_position = player.position
			player.target.x = player.position.x 
			player.target.y = player.position.y - 32
			
		elif event.is_action_pressed("ui_down"):
			player.moving = true
			player.actual_position = player.position
			player.target.x = player.position.x
			player.target.y = player.position.y + 32
