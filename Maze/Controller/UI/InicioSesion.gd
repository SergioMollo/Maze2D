extends Control


# Inica los datos cuando se instancia por primera vez
func _ready():
	Singleton._ready()
	get_window().content_scale_size = Singleton.initial_resolution
	Singleton.connect("set_text_info", on_set_text_info)


# Inicia sesion con las credenciales de usuario indicadas
# 	- Comprueba que las credenciales son correctas 
# 	- Comprueba que las credenciales corresponden a un usuario registrado
func _on_iniciar_sesion_pressed():
	var email = $Canvas/Panel/Margin/VBox/EmailValue.text
	var password = $Canvas/Panel/Margin/VBox/PasswordValue.text
	Singleton.login(email, password)


# Cierra la aplicacion cuando se presiona el boton "Salir"
func _on_salir_pressed():
	get_tree().quit()


# Abre el menu de registro cuando se presiona el boton "Registro"
func _on_registro_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/Registro.tscn")
	
	
# Cierra la aplicacion
func _on_close_pressed() -> void:
	get_tree().quit()
	
	
# Minimiza la aplicacion
func _on_minimize_pressed() -> void:
	get_tree().root.mode = Window.MODE_MINIMIZED
	
	
# Muestra el texto correspondiente a la comprobacion de inicio de sesion
func on_set_text_info(message: String, color: Color):
	var info_sesion = $Canvas/Panel/Margin/VBox/Margin/InfoSesion
	info_sesion.text = message
	info_sesion.modulate = color
