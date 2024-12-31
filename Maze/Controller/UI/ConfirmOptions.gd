extends Control

var maze: MazeController

# Sale de la partida al menu principal, guardando el progreso alcanzado
func _on_guardar_salir_pressed():
	maze.match_state = VideogameConstants.EstadoPartida.GUARDADA
	maze.game_state = VideogameConstants.EstadoJuego.EN_PAUSA
	save()


# Finaliza la partida al menu principal, guardando el progreso alcanzado
func _on_finalizar_pressed():
	maze.match_state = VideogameConstants.EstadoPartida.FINALIZADA
	maze.game_state = VideogameConstants.EstadoJuego.FINALIZADO
	await save()
	Singleton.partida_reference = ""
	Singleton.nombre_partida = ""
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


# Reinicia completamente la partida al estado inicial
func _on_reiniciar_pressed():
	maze.game_number = 0
	maze.win = 0
	maze.lose = 0
	maze.time_left = maze.maze.time
	maze.updatePuntuation()
	maze.new_game()
	queue_free()


# Sale de la partida al menu principal, sin guardar el progreso alcanzado
func _on_menu_principal_pressed() -> void:
	Singleton.partida_reference = ""
	Singleton.nombre_partida = ""
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


# Cancela la secuencia y cierra el menu
func _on_cancelar_pressed():
	queue_free()
	
	
#  Muestra el mensaje en funcion del tipo de opcion seleccionada en el menu anterior
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
	elif option == "MenuPrincipal":
		$Panel/VBox/Margin2/HBoxContainer/MenuPrincipal.show()
		$Panel/VBox/Margin2/HBoxContainer/GuardarSalir.show()
		info.text = "Podra salir de la partida al menú principal 
					almacenando el progreso alcanzado.
					¿Está seguro que desea salir de la partida? "


# Guarda el progreso alcanzado en la partida
#  	- Si la partida no se ha guardado anteriormente se crea una nueva entrada en la BBDD
#  	- Si la partida se ha guardado anteriormente se actualiza esa entrada (partida) en la BBDD
func save():
	if Singleton.nombre_partida == "":
		var overlay_scene = preload("res://Maze/View/UI/GuardarPartida.tscn")
		var instance = overlay_scene.instantiate()
		add_child(instance)
		instance.position = Vector2(0,0)
		instance.setMaze(maze)
	else:
		maze.saveGame(Singleton.nombre_partida)

	Singleton.connect("save_completed", _on_save_completed)


func _on_save_completed():
	print("Entro aqui")
	Singleton.partida_reference = ""
	Singleton.nombre_partida = ""	
	queue_free()
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")
