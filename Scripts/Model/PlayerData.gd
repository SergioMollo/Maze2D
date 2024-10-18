extends "res://Scripts/Model/CharacterData.gd"

class_name Player

var algoritmo_busqueda: Algorithm

#var maze_finished = false
#var wall_collide = false
#var result = []
#var target = Vector2.ZERO

#@export var speed = 320
#@export var velocity = 0


#@onready var navigation: NavigationAgent2D = $NavigationAgent2D
#@onready var ai_controller: Node2D = $AIController2D
#@onready var moneda: Area2D = $"../Moneda/Moneda2D"

func _init():
	position = Vector2.ZERO
	global_position = Vector2.ZERO
	print("creando")
	set_physics_process(false)
	call_deferred("sync_frames")
	#await get_tree().physics_frame
	#makepath()

func _ready():
	position = Vector2.ZERO
	global_position = Vector2.ZERO
	print("creando")
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

func move(target: Vector2):

	velocity = position.direction_to(target) * speed
	# look_at(target)
	
	if position.distance_to(target) > 1:	
		print("muevo")		
		move_and_slide()
		if position.distance_to(target) < 1:
			global_position = target

	print(position)
	print(global_position)
