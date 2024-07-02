extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Nivel1.grab_focus()

func _on_nivel_1_pressed():
	get_tree().change_scene_to_file("res://Scenes/LaberintoNivel1.tscn")

func _on_nivel_2_pressed():
	get_tree().change_scene_to_file("res://Scenes/LaberintoNivel2.tscn")

func _on_nivel_3_pressed():
	get_tree().change_scene_to_file("res://Scenes/LaberintoNivel3.tscn")

func _on_aleatorio_pressed():
	pass # Replace with function body.

func _on_salir_pressed():
	get_tree().quit()
