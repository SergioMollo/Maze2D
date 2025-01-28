extends Control

# Muestra el menu de configuración durante la partida al presionar el boton de configuración
func _on_configuration_pressed():
	var overlay_scene = preload("res://Maze/View/UI/GameOptions.tscn")
	var instance = overlay_scene.instantiate()
	var labirytnm = get_node("../../Maze")
	await labirytnm.stopTimer()
	instance.setMaze(labirytnm)
	$"..".add_child(instance)
	instance.position = Vector2(labirytnm.maze.scale.x/2,labirytnm.maze.scale.y/2)
