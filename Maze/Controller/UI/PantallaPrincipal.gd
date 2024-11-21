extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution
	$CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CrearPartida.grab_focus()
	

func _on_crear_partida_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/CrearPartida.tscn")


func _on_continuar_partida_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/ContinuarPartida.tscn")


func _on_ajustes_pressed():
	var overlay_scene = preload("res://Maze/View/UI/Configuracion.tscn")
	var node = $"."
	node.modulate.a = 0.5
	var instance = overlay_scene.instantiate()
	add_child(instance)

	
func _on_salir_pressed():
	get_tree().quit()


func _on_apariencia_jugador_pressed():
	Singleton.selection = "player"
	get_tree().change_scene_to_file("res://Maze/View/UI/SeleccionarApariencia.tscn")


func _on_apariencia_enemigo_pressed():
	Singleton.selection = "enemy"
	get_tree().change_scene_to_file("res://Maze/View/UI/SeleccionarApariencia.tscn")
