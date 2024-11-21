extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_configuration_pressed():
	print("Configuracion")
	var overlay_scene = preload("res://Maze/View/UI/GameOptions.tscn")
	var instance = overlay_scene.instantiate()
	add_child(instance)
	var labirytnm = get_node("../../Maze")
	instance.position = Vector2(labirytnm.maze.scale.x/2,labirytnm.maze.scale.y/2)


func _on_pause_pressed():
	pass # Replace with function body.
