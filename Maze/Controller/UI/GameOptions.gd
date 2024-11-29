extends Control


var maze: MazeController

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_window().content_scale_size = Vector2(800,800)
	maze.game_state = VideogameConstants.EstadoJuego.EN_PAUSA
	$PanelContainer/Container/Tipo/Juego.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_juego_pressed():
	$PanelContainer/Container/Tipo/Juego.grab_focus()
	$PanelContainer/Container/GeneralOptions.visible = false
	$PanelContainer/Container/Margin/Info/GeneralLabel.visible = false
	$PanelContainer/Container/JuegoOptions.visible = true
	$PanelContainer/Container/Margin/Info/JuegoLabel.visible = true


func _on_general_pressed():
	print("General")
	$PanelContainer/Container/Tipo/General.grab_focus()
	$PanelContainer/Container/JuegoOptions.visible = false
	$PanelContainer/Container/Margin/Info/JuegoLabel.visible = false
	$PanelContainer/Container/GeneralOptions.visible = true
	$PanelContainer/Container/Margin/Info/GeneralLabel.visible = true


func _on_guardar_pressed():
	var overlay_scene = preload("res://Maze/View/UI/GuardarPartida.tscn")
	var instance = overlay_scene.instantiate()
	add_child(instance)
	instance.position = Vector2(0,0)
	instance.setMaze(maze)


func _on_reiniciar_pressed():
	var overlay_scene = preload("res://Maze/View/UI/ConfirmOptions.tscn")
	var instance = overlay_scene.instantiate()
	add_child(instance)
	instance.position = Vector2(0,0)
	instance.setOptions(maze, "Reiniciar")


func _on_cambiar_configuracion_pressed():
	var overlay_scene = preload("res://Maze/View/UI/CambiarConfiguracion.tscn")
	var instance = overlay_scene.instantiate()
	add_child(instance)
	instance.position = Vector2(0,0)
	instance.setMaze(maze)


func _on_finalizar_pressed():
	var overlay_scene = preload("res://Maze/View/UI/ConfirmOptions.tscn")
	var instance = overlay_scene.instantiate()
	add_child(instance)
	instance.position = Vector2(0,0)
	instance.setOptions(maze, "Finalizar")


func _on_salir_pressed():
	var overlay_scene = preload("res://Maze/View/UI/ConfirmOptions.tscn")
	var instance = overlay_scene.instantiate()
	add_child(instance)
	instance.position = Vector2(0,0)
	instance.setOptions(maze, "Salir")


func _on_continuar_pressed():
	maze.game_state = VideogameConstants.EstadoJuego.EN_CURSO
	queue_free()


func _on_cerrar_pressed():
	maze.game_state = VideogameConstants.EstadoJuego.EN_CURSO
	queue_free()


func _on_juego_button_pressed() -> void:
	$PanelContainer/Container/Tipo/JuegoButton.grab_focus()
	
	
func setMaze(maze_instance):
	maze = maze_instance
