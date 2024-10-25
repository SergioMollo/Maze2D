extends "res://Scripts/Model/CharacterData.gd"

class_name Player

var algoritmo_busqueda: Algorithm

#var maze_finished = false
#var wall_collide = false
#var result = []

#@onready var navigation: NavigationAgent2D = $NavigationAgent2D
#@onready var ai_controller: Node2D = $AIController2D
#@onready var moneda: Area2D = $"../Moneda/Moneda2D"

func _ready():
	position = Vector2.ZERO
	global_position = Vector2.ZERO
	print("ready")
	set_physics_process(false)
	call_deferred("sync_frames")
	#await get_tree().physics_frame
	#makepath()
	
func sync_frames():
	#await get_tree().physics_frame
	set_physics_process(true)

#### Crear path
#func makepath():
	#navigation.target_position = moneda.global_position

#func _on_timer_timeout():
	#makepath()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# func move():
# 	# Comprobacion de que ha habido colision mantener posicion actual
# 	if get_slide_collision_count() > 0:
# 		print("Que")
# 		position = actual_position
# 		moving = false
# 		velocity = Vector2()
				
# 	# Si estamos muy cerca de la posición objetivo, corregimos la posición final
# 	elif position.distance_to(target) < 1:
# 		print("Pasa")
# 		position = target
# 		velocity = Vector2()  # Detenemos el movimiento
# 		moving = false
