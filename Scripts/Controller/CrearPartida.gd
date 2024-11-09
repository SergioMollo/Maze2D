extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_atras_pressed():
	get_tree().change_scene_to_file("res://Scenes/PantallaPrincipal.tscn")


func _on_crear_partida_pressed():
	var nivel_option = $HBoxContainer/VBoxContainer/NivelOption
	var nivel = nivel_option.get_selected()
	if nivel == 0:
		get_tree().change_scene_to_file("res://Scenes/LaberintoNivel1.tscn")
	elif nivel == 1:
		get_tree().change_scene_to_file("res://Scenes/LaberintoNivel2.tscn")
	elif nivel == 2:
		get_tree().change_scene_to_file("res://Scenes/LaberintoNivel3.tscn")
	elif nivel == 3:
		print("El nivel aleatorio aun no esta implementado")
		var information = $information
		information.text = "El nivel aleatorio aun\n no esta implementado"
