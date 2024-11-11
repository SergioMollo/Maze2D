extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CrearPartida.grab_focus()
	

func _on_crear_partida_pressed():
	get_tree().change_scene_to_file("res://Scenes/CrearPartida.tscn")


func _on_continuar_partida_pressed():
	get_tree().change_scene_to_file("res://Scenes/ContinuarPartida.tscn")


func _on_seleccionar_apariencia_pressed():
	get_tree().change_scene_to_file("res://Scenes/SeleccionarApariencia.tscn")


func _on_ajustes_pressed():
	var overlay_scene = preload("res://Scenes/Configuracion.tscn")
	var node = $"."
	node.modulate.a = 0.5
	var instance = overlay_scene.instantiate()
	add_child(instance)

	
func _on_salir_pressed():
	get_tree().quit()


