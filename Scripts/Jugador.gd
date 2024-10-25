extends CharacterBody2D


var algoritmo

var moving = false
var maze_finished = false
var wall_collide = false
var result = []


@export var speed = 80
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var ai_controller: Node2D = $AIController2D
@onready var moneda: Area2D = $"../Moneda/Moneda2D"

var target = Vector2.ZERO
var actual_position = position

func _ready():
	position = Vector2.ZERO
	global_position = Vector2.ZERO
	set_physics_process(false)
	call_deferred("sync_frames")
	#await get_tree().physics_frame
	makepath()
	
func sync_frames():
	await get_tree().physics_frame
	set_physics_process(true)

func _physics_process(delta):
	await get_tree().physics_frame
	if !maze_finished:
		# #Resuelve el laberinto en base al algoritmo de busqueda
		# for destino in result:
			
			
		# 	var fila = (destino / 10)*32 + 16
		# 	var columna = (destino % 10)*32 + 16
		# 	target = Vector2(columna, fila)
			
		# 	velocity = position.direction_to(target) * speed
		# 	# look_at(target)
		# 	print("Target", target)
		# 	print("Actual", position)
		# 	if position.distance_to(target) > 1:
				
				
		# 		# No se desplaza a la posicion exacta, por lo que no mueve correctamente
		# 		# y se queda bloqueado
		# 		move_and_slide()
		# 		if position.distance_to(target) < 1:
		# 			global_position = target
					
					
		# 	await get_tree().create_timer(1.0).timeout
			
		
		
		###########Busqueda bfs
		#var next_path_position = navigation.get_next_path_position()
		#var direction = (next_path_position - global_position).normalized()

		#var direction = to_local(navigation.get_next_path_position()).normalized()
		#velocity = direction * speed
		#move_and_slide()
		
		########### Movimiento al destino
		#velocity = position.direction_to(target) * speed
			## look_at(target)
		#if position.distance_to(target) > 1:
			#
			##move_and_slide()
			#move_and_slide()
			#if get_slide_collision_count() == 0:
				#print(position)
				#if position.distance_to(target) < 1:
					#global_position = target
					#print(position)
					#print(global_position)
					
		if position != target and moving:
			var direction = (target - position).normalized()
			velocity = direction * speed
			move_and_slide()
			
			# Comprobacion de que ha habido colision mantener posicion actual
			if get_slide_collision_count() > 0:
				position = actual_position
				moving = false
				velocity = Vector2()
				
			# Si estamos muy cerca de la posición objetivo, corregimos la posición final
			elif position.distance_to(target) < 1:
				position = target
				velocity = Vector2()  # Detenemos el movimiento
				moving = false
				
			
		########### Movimiento de la ia                         
		#velocity.x = ai_controller.move.x * speed
		#velocity.y = ai_controller.move.y * speed
		#move_and_slide()

	# Comprobar si el personaje está fuera de los límites del mapa
	#var posicion = global_position
	#if posicion.x < limite_izquierdo:
		#posicion.x = limite_izquierdo
		#global_position = posicion
#
	## Actualizar la posición del personaje
	#global_position = posicion


#### Crear path
func makepath():
	navigation.target_position = moneda.global_position

## Registrar movimiento manual en base a las cuatro direcciones (arriba, abajo, izquierda, derecha)
func _input(event):
	if !moving:
		if event.is_action_pressed("ui_right"):
			actual_position = position
			target.x = position.x + 32
			target.y = position.y
			moving = true
			
		if event.is_action_pressed("ui_left"):
			actual_position = position
			target.x = position.x - 32
			target.y = position.y
			moving = true
			
		if event.is_action_pressed("ui_up"):
			actual_position = position
			target.x = position.x 
			target.y = position.y - 32
			moving = true
			
		if event.is_action_pressed("ui_down"):
			actual_position = position
			target.x = position.x
			target.y = position.y + 32
			moving = true

func move():
	velocity = position.direction_to(target) * speed
	# look_at(target)
	if position.distance_to(target) > 1:			
		#move_and_slide()
		move_and_slide()
		if position.distance_to(target) < 1:
			global_position = target


############################### Algoritmos de entrenamiento ###############################

######## Busqueda en anchura ########

var visited = []
var solve_path = {}

func game_bfs():


	# Obtener las posiciones de inicio y fin (por ejemplo, posición del jugador y posición de la salida)
	var start_pos = global_position
	var end_pos = moneda.global_position 

	visited.append(start_pos)

	var path = bfs(start_pos, end_pos)

	if path:
		print("Ruta encontrada:", path)
	else:
		print("No se encontró una ruta.")

func bfs(start_pos, end_pos):

	var left = Vector2(start_pos.x - 32, start_pos.y)
	var right = Vector2(start_pos.x + 32, start_pos.y)
	var up = Vector2(start_pos.x, start_pos.y - 32)
	var down = Vector2(start_pos.x, start_pos.y + 32)

	for i in range(1, 5):
		global_position = start_pos
		


	var info = move_and_slide()
	
	if info:
		if info.collider_id == get_node("TileMap").get_instance_id():
			wall_collide = true


func _on_timer_timeout():
	makepath()
