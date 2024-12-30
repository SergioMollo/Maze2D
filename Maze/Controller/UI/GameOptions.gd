extends Control


var maze: MazeController

# Inica los datos cuando se instancia por primera vez
func _ready():
	$PanelContainer/Container/Tipo/Juego.grab_focus()


#  Muestra las opciones de configuracion de la partida
# 	- Al seleccionar el boton "Juego"
func _on_juego_pressed():
	$PanelContainer/Container/Tipo/Juego.grab_focus()
	$PanelContainer/Container/GeneralOptions.visible = false
	$PanelContainer/Container/Margin/Info/GeneralLabel.visible = false
	$PanelContainer/Container/JuegoOptions.visible = true
	$PanelContainer/Container/Margin/Info/JuegoLabel.visible = true


#  Muestra las opciones de configuracion general
# 	- Al seleccionar el boton "General"
func _on_general_pressed():
	$PanelContainer/Container/Tipo/General.grab_focus()
	$PanelContainer/Container/JuegoOptions.visible = false
	$PanelContainer/Container/Margin/Info/JuegoLabel.visible = false
	$PanelContainer/Container/GeneralOptions.visible = true
	$PanelContainer/Container/Margin/Info/GeneralLabel.visible = true


# Guarda las opciones de configuracion establecidas
# 	- Muestra el menu de guardado de partida
func _on_guardar_pressed():
	var overlay_scene = preload("res://Maze/View/UI/GuardarPartida.tscn")
	var instance = overlay_scene.instantiate()
	instance.setMaze(maze)
	add_child(instance)
	instance.position = Vector2(0,0)


# Reinicia la partida con las opciones de configuracion establecidas
# 	- Muestra el menu de reinicio de partida 
func _on_reiniciar_pressed():
	var overlay_scene = preload("res://Maze/View/UI/ConfirmOptions.tscn")
	var instance = overlay_scene.instantiate()
	instance.setOptions(maze, "Reiniciar")
	add_child(instance)
	instance.position = Vector2(0,0)


# Cambia las opciones de configuracion establecidas
# 	- Muestra el menu de cambiar configuracion de la partida
func _on_cambiar_configuracion_pressed():
	var overlay_scene = preload("res://Maze/View/UI/CambiarConfiguracion.tscn")
	var instance = overlay_scene.instantiate()
	instance.setMaze(maze)
	add_child(instance)
	instance.position = Vector2(0,0)


# Finaliza la partida guardando el progreso
# 	- Muestra el menu de finalizar partida
func _on_finalizar_pressed():
	var overlay_scene = preload("res://Maze/View/UI/ConfirmOptions.tscn")
	var instance = overlay_scene.instantiate()
	instance.setOptions(maze, "Finalizar")
	add_child(instance)
	instance.position = Vector2(0,0)


# Sale de la partida, permitiendo guardar el progreso
# 	- Muestra el menu de salir de la partida
func _on_salir_pressed():
	var overlay_scene = preload("res://Maze/View/UI/ConfirmOptions.tscn")
	var instance = overlay_scene.instantiate()
	instance.setOptions(maze, "MenuPrincipal")
	add_child(instance)
	instance.position = Vector2(0,0)


# Continua la partida con las opciones de configuracion establecidas
# 	- Cierra el menu de configuracion de partida
func _on_continuar_pressed():
	maze.game_state = VideogameConstants.EstadoJuego.EN_CURSO
	queue_free()
	if maze.initiate:
		print("Pa dentro")
		maze.continueTimer(maze.time_left)
		maze.game_process()


# Cierra el menu de configuracion de partida, y continua el juego
func _on_cerrar_pressed():
	maze.game_state = VideogameConstants.EstadoJuego.EN_CURSO
	queue_free()
	if maze.initiate:
		print("Pa dentro")
		maze.continueTimer(maze.time_left)
		maze.game_process()
	

# Asigna la instancia del script del laberinto, y pausa el juego
func setMaze(maze_instance):
	maze = maze_instance
	maze.game_state = VideogameConstants.EstadoJuego.EN_PAUSA
