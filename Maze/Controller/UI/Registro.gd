extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_crear_cuenta_pressed():
	
	# Crear cuerta y almacenar en base de datos
	
	get_tree().change_scene_to_file("res://Maze/View/UI/InicioSesion.tscn")


func _on_cancelar_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/InicioSesion.tscn")
