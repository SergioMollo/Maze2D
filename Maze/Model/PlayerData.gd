extends "res://Maze/Model/CharacterData.gd"

class_name Player

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
