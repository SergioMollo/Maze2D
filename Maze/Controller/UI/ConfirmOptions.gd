extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_guardar_salir_pressed():
	# Guardar y salir
	
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_finalizar_pressed():
	# Guardar y salir finalizando partida 
	
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_reiniciar_pressed():
	
	# Reiniciar partida y borrar datos
	
	get_tree().change_scene_to_file("res://Maze/View/UI/LaberintoNivel1.tscn")


func _on_salir_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_cancelar_pressed():
	queue_free()
