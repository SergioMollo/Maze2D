extends "res://Maze/Model/CharacterData.gd"

class_name Player

#@onready var navigation: NavigationAgent2D = $NavigationAgent2D
#@onready var ai_controller: Node2D = $AIController2D
#@onready var moneda: Area2D = $"../Moneda/Moneda2D"

func _ready():
	position = Vector2.ZERO
	global_position = Vector2.ZERO
	set_physics_process(false)
	call_deferred("sync_frames")
	
func sync_frames():
	set_physics_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
