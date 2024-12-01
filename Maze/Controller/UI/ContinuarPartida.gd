extends Control

var partidas: Array = []
var finalizadas: Array = []
var partida_selected: Dictionary
@onready var listado = $Canvas/VBox/Margin/VBox/HBox/Scroll/ListaPartidas


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution
	var listas = await Singleton.loadGames()
	partidas = listas[0]
	finalizadas = listas[1]
	printGames()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_name_label_pressed(button) -> void:
	var panel = button.get_parent().get_parent().get_parent()
	var index_panel = listado.get_children().find(panel)
	printExtensionGame(partidas[index_panel])


func _on_seleccionar_button_pressed():	
	Singleton.initSaveGame(partida_selected)


func _on_atras_button_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")
	
	
func printGames():
	var panel_partidas = $PanelPartida
	
	for partida in partidas:
		var new_panel = panel_partidas.duplicate()
		var button_name = new_panel.get_node("./HBox/Informacion/NameLabel")
		button_name.text = partida["nombre"]
		new_panel.get_node("./HBox/Informacion/Margin1/Fila1/LevelValueLabel").text = "Nivel: " + Singleton.getNivelString(partida["nivel"])
		new_panel.get_node("./HBox/Informacion/Margin1/Fila1/TimeLabel").text = "00:20"
		new_panel.get_node("./HBox/Informacion/Margin2/Fila2/ResultLabel").text = str(partida["win_games"]) + " - " + str(partida["lose_games"])
		new_panel.get_node("./HBox/Informacion/Margin2/Fila2/DateSaveLabel").text = "30/11/2024"
		new_panel.show()
		button_name.pressed.connect(_on_name_label_pressed.bind(button_name))
		listado.add_child(new_panel)
		

func printExtensionGame(partida: Dictionary):
	partida_selected = partida
	var panel_extension = $Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel
	
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/NameLabel.text = partida["nombre"]
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/LevelLabel.text = Singleton.getNivelString(partida["nivel"])
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/ResultLabel.text = str(partida["win_games"]) + " - " + str(partida["lose_games"])
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer2/DifficultyValue.text = Singleton.getDificultadString(partida["dificultad"])
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer2/ModoJuegoValue.text = Singleton.getModoJuegoString(partida["modo_juego"])
	$Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer2/ModoInteraccionValue.text = Singleton.getModoInteraccionString(partida["modo_interaccion"])
	
	var value_algoritmo = $Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer2/AlgorithmValue
	var label_algoritmo = $Canvas/VBox/Margin/VBox/HBox/Extension/AmpliationPanel/Margin/VBox/HBoxContainer/VBoxContainer/AlgorithmLabel
	
	if partida["algoritmo_jugador"] != 4:	
		value_algoritmo.text = Singleton.getAlgoritmoString(partida["algoritmo_jugador"])
		value_algoritmo.show()
		label_algoritmo.show()	
	elif partida.has("algoritmo_enemigo") :
		if partida["algoritmo_enemigo"] != 4:	
			value_algoritmo.text = Singleton.getAlgoritmoString(partida["algoritmo_enemigo"])
			value_algoritmo.show()
			label_algoritmo.show()
	else:
		value_algoritmo.hide()
		label_algoritmo.hide()
		
	panel_extension.show()
		
	
