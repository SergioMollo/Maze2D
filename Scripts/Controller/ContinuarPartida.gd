extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_seleccionar_button_pressed():
	var nivel = $CanvasLayer/PanelFondo/VBoxContainer/MarginContainer2/HBoxContainer/ResumePanel/MarginContainer/ContainerListaPartidas/ContainerPartida/HBoxContainer/LevelValueLabel
	if nivel == VideogameConstants.Nivel.NIVEL1:
		get_tree().change_scene_to_file("res://Scenes/LaberintoNivel1.tscn")
	if nivel == VideogameConstants.Nivel.NIVEL2:
		get_tree().change_scene_to_file("res://Scenes/LaberintoNivel2.tscn")
	if nivel == VideogameConstants.Nivel.NIVEL2:
		get_tree().change_scene_to_file("res://Scenes/LaberintoNivel3.tscn")
	if nivel == VideogameConstants.Nivel.ALEATORIO:
		get_tree().change_scene_to_file("res://Scenes/LaberintoNivel1.tscn")


func _on_atras_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/PantallaPrincipal.tscn")
