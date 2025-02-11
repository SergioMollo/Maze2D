extends Control

var maze_instance: MazeController

var bus_index = AudioServer.get_bus_index("Master")
var volume_value
var resolution_text

# Inica los datos cuando se instancia por primera vez
func _ready():
	$PanelContainer/Container/Tipo/Juego.grab_focus()
	var volume = $PanelContainer/Container/GeneralOptions/Volume/VolumeSlider
	var resolution = $PanelContainer/Container/GeneralOptions/Resolution/ResolutionOption
	
	volume_value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	volume.value = volume_value
	var resolution_value = get_window().size
	resolution_text = str(resolution_value.x) + "x" + str(resolution_value.y)
	if resolution_text == "1920x1080":
		resolution.selected = 0
	elif resolution_text == "1280x720":
		resolution.selected = 1
	elif resolution_text == "960x540":
		resolution.selected = 2
	elif resolution_text == "640x480":
		resolution.selected = 3


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
	instance.setMaze(maze_instance)
	add_child(instance)
	instance.position = Vector2(0,0)


# Reinicia la partida con las opciones de configuracion establecidas
# 	- Muestra el menu de reinicio de partida 
func _on_reiniciar_pressed():
	var overlay_scene = preload("res://Maze/View/UI/ConfirmOptions.tscn")
	var instance = overlay_scene.instantiate()
	instance.setOptions(maze_instance, "Reiniciar")
	add_child(instance)
	instance.position = Vector2(0,0)
	instance.connect("menu_closed", Callable(self, "_on_confirm_options_closed")) 

# Cambia las opciones de configuracion establecidas
# 	- Muestra el menu de cambiar configuracion de la partida
func _on_cambiar_configuracion_pressed():
	var overlay_scene = preload("res://Maze/View/UI/CambiarConfiguracion.tscn")
	var instance = overlay_scene.instantiate()
	instance.setMaze(maze_instance)
	add_child(instance)
	instance.position = Vector2(0,0)


# Finaliza la partida guardando el progreso
# 	- Muestra el menu de finalizar partida
func _on_finalizar_pressed():
	var overlay_scene = preload("res://Maze/View/UI/ConfirmOptions.tscn")
	var instance = overlay_scene.instantiate()
	instance.setOptions(maze_instance, "Finalizar")
	add_child(instance)
	instance.position = Vector2(0,0)


# Sale de la partida, permitiendo guardar el progreso
# 	- Muestra el menu de salir de la partida
func _on_salir_pressed():
	var overlay_scene = preload("res://Maze/View/UI/ConfirmOptions.tscn")
	var instance = overlay_scene.instantiate()
	instance.setOptions(maze_instance, "MenuPrincipal")
	add_child(instance)
	Videogame.setPrincipalMusic()
	instance.position = Vector2(0,0)


# Continua la partida con las opciones de configuracion establecidas
# 	- Cierra el menu de configuracion de partida
func _on_continuar_pressed():
	#var resolution = $PanelContainer/Container/GeneralOptions/Resolution/ResolutionOption
	#var resolution_value = resolution.get_item_text(resolution.get_selected())
	#if resolution_text != resolution_value:
		#resolution_value.split("x")
		#get_window().size = Vector2(int(resolution_value[0]), int(resolution_value[1]))
		
	maze_instance.game.estado = VideogameConstants.EstadoJuego.EN_CURSO
	queue_free()
	if maze_instance.initiate:
		maze_instance.continueTimer(maze_instance.game.tiempo_restante)
		maze_instance.gameProcess()


# Cierra el menu de configuracion de partida, y continua el juego
func _on_cerrar_pressed():
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume_value))
	maze_instance.game.estado = VideogameConstants.EstadoJuego.EN_CURSO
	queue_free()
	if maze_instance.initiate:
		maze_instance.continueTimer(maze_instance.game.tiempo_restante)
		maze_instance.gameProcess()
	

# Asigna la instancia del script del laberinto, y pausa el juego
func setMaze(instance):
	maze_instance = instance
	maze_instance.game.estado = VideogameConstants.EstadoJuego.EN_PAUSA


func _on_volume_slider_value_changed(value: float) -> void:
	var volume = $PanelContainer/Container/GeneralOptions/Volume/VolumeSlider
	
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(volume.value)
	)


func _on_confirm_options_closed():
	maze_instance.game.estado = VideogameConstants.EstadoJuego.EN_CURSO
	queue_free()
	if maze_instance.initiate:
		maze_instance.continueTimer(maze_instance.game.tiempo_restante)
		maze_instance.gameProcess()
	
