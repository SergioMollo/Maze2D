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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
