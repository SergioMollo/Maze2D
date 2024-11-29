extends Control

var maze: MazeController

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_guardar_salir_pressed():
	maze.match_state = VideogameConstants.EstadoPartida.GUARDADA
	maze.game_state = VideogameConstants.EstadoJuego.EN_PAUSA
	save()
	Singleton.partida_reference = ""
	Singleton.nombre_partida = ""	
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_finalizar_pressed():
	maze.match_state = VideogameConstants.EstadoPartida.FINALIZADA
	maze.game_state = VideogameConstants.EstadoJuego.FINALIZADO
	save()
	Singleton.partida_reference = ""
	Singleton.nombre_partida = ""
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_reiniciar_pressed():
	maze.juegos = 0
	maze.win = 0
	maze.lose = 0
	maze.match_state = VideogameConstants.EstadoPartida.EN_CURSO
	maze.game_state = VideogameConstants.EstadoJuego.EN_CURSO
	maze.updatePuntuation()
	maze.new_game()
	queue_free()


func _on_salir_pressed():
	Singleton.partida_reference = ""
	Singleton.nombre_partida = ""
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_cancelar_pressed():
	queue_free()
	
	
func setOptions(maze_instance: MazeController, option: String):
	maze = maze_instance
	$Panel/VBox/Margin/VBox/Option.text = option
	var info = $Panel/VBox/Info
	
	if option == "Finalizar":
		$Panel/VBox/Margin2/HBoxContainer/Finalizar.show()
		info.text = "Esta acción almacena el progreso alcanzado.
					Si actualmente se encuentra un juego en curso
					este se establecerá como empate.
					Tras esta acción solo podrá visualizar sus datos.
					¿Está seguro que desea finalizar la partida? "
	elif option == "Reiniciar":
		$Panel/VBox/Margin2/HBoxContainer/Reiniciar.show()
		info.text = "Esta acción reinicia la partida sin guardar 
					el progreso alcanzado hasta el momento.
					¿Está seguro que desea reiniciar la partida? "
	elif option == "Salir":
		$Panel/VBox/Margin2/HBoxContainer/Salir.show()
		$Panel/VBox/Margin2/HBoxContainer/GuardarSalir.show()
		info.text = "Podra salir de la partida al menú principal 
					almacenando el progreso alcanzado.
					¿Está seguro que desea salir de la partida? "


func save():
	if Singleton.nombre_partida == "":
		var overlay_scene = preload("res://Maze/View/UI/GuardarPartida.tscn")
		var instance = overlay_scene.instantiate()
		add_child(instance)
		instance.position = Vector2(0,0)
		instance.setMaze(maze)
	else:
		maze.saveGame(Singleton.nombre_partida)
