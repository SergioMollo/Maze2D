extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Singleton._ready()
	get_window().content_scale_size = Singleton.initial_resolution
	Singleton.connect("set_text_info", on_set_text_info)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_iniciar_sesion_pressed():
	var email = $Canvas/Panel/Margin/VBox/EmailValue.text
	var password = $Canvas/Panel/Margin/VBox/PasswordValue.text
	Singleton.login(email, password)
	#get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_salir_pressed():
	get_tree().quit()


func _on_registro_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/Registro.tscn")
	
	
func on_set_text_info(message: String, color: Color):
	var info_sesion = $Canvas/Panel/Margin/VBox/Margin/InfoSesion
	info_sesion.text = message
	info_sesion.modulate = color
