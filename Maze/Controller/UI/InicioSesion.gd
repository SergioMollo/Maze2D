extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_iniciar_sesion_pressed():
	# Comprobar con base de datos que es un usuario registrado
	
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_salir_pressed():
	queue_free()


func _on_registro_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/Registro.tscn")
	
