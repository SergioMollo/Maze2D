extends Control

var partidas: Array = []
var finalizadas: Array = []
var partida_selected: Dictionary
@onready var listado = $Canvas/VBox/Margin/VBox/HBox/Scroll/ListaPartidas


# Inica los datos cuando se instancia por primera vez
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution
	var listas = Singleton.loadGames()
	partidas = listas[0]
	finalizadas = listas[1]
	printGames()


#  Cuando se presiona el nombre de una partida de la lista
# 	- Se almacena el identificador de la partida seleccionada
# 	- Se muestra un cuadro con informacion ampliada de la partida
func _on_name_label_pressed(button) -> void:
	var panel = button.get_parent().get_parent().get_parent()
	var index_panel = listado.get_children().find(panel)
	printExtensionGame(partidas[index_panel])


# Al presionar el boton "Seleccionar" con una partida elegida 
# 	- Se inicia un nuevo juego con los datos de la partida cargada
func _on_seleccionar_button_pressed():	
	Singleton.initSaveGame(partida_selected)


# Vuelve al menu principal al presionar el boton "Atras"
func _on_atras_button_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")
	

# Muestra las partidas del usuario en una lista
# 	- Los datos mostrados son un resumen de la partida
# 	- Muestra el boton seleccionable de cada partida
# 	- El boton permite mostrar información más detallada de la partida seleccionada
func printGames():
	var panel_partidas = $PanelPartida
	
	for partida in partidas:
		var new_panel = panel_partidas.duplicate()
		var button_name = new_panel.get_node("./HBox/Informacion/NameLabel")
		var resultado = partida["resultado"].split(",")

		button_name.text = partida["nombre"]
		new_panel.get_node("./HBox/Informacion/Margin1/Fila1/LevelValueLabel").text = "Nivel: " + Singleton.getNivelString(partida["nivel"])
		new_panel.get_node("./HBox/Informacion/Margin1/Fila1/TimeLabel").text = str(partida["tiempo_restante"])
		new_panel.get_node("./HBox/Informacion/Margin2/Fila2/ResultLabel").text = resultado[0] + "-" + resultado[1]
		new_panel.get_node("./HBox/Informacion/Margin2/Fila2/DateSaveLabel").text = partida["fecha"]
		new_panel.show()
		button_name.pressed.connect(_on_name_label_pressed.bind(button_name))
		listado.add_child(new_panel)
		

# Muestra en detalle los datos de la partida seleccionada
# 	- Los datos se muestran en un menu lateral
func printExtensionGame(partida: Dictionary):
	partida_selected = partida
	var panel_extension = $Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel
	var resultado = partida["resultado"].split(",")
	
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/NameLabel.text = partida["nombre"]
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/LevelLabel.text = Singleton.getNivelString(partida["nivel"])
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/ResultLabel.text = resultado[0] + "-" + resultado[1]
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer2/DifficultyValue.text = Singleton.getDificultadString(partida["dificultad"])
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer2/ModoJuegoValue.text = Singleton.getModoJuegoString(partida["modo_juego"])
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer2/ModoInteraccionValue.text = Singleton.getModoInteraccionString(partida["modo_interaccion"])
	
	var value_algoritmo = $Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer2/AlgorithmValue
	var label_algoritmo = $Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer/AlgorithmLabel
	
	if partida["algoritmo_jugador"] != 4:	
		value_algoritmo.text = Singleton.getAlgoritmoString(partida["algoritmo_jugador"])
		value_algoritmo.show()
		label_algoritmo.show()	
	if partida["algoritmo_enemigo"] != null:	
			value_algoritmo.text = Singleton.getAlgoritmoString(partida["algoritmo_enemigo"])
			value_algoritmo.show()
			label_algoritmo.show()
	else:
		value_algoritmo.hide()
		label_algoritmo.hide()
		
	panel_extension.show()
		
	
