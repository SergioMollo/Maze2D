extends Control


# Inica los datos cuando se instancia por primera vez
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution
	Singleton.connect("set_text_info", on_set_text_info)


# Crea una cuenta de usuario con los credenciales introducidos
func _on_crear_cuenta_pressed():
	var nombre = $Canvas/Panel/Margin/VBox/NombreValue.text
	var email = $Canvas/Panel/Margin/VBox/EmailValue.text
	var password = $Canvas/Panel/Margin/VBox/PasswordValue.text
	var password_confirm = $Canvas/Panel/Margin/VBox/PasswordConfirmValue.text
	
	if password == password_confirm:
		Singleton.signUp(email, password, nombre)	


# Cancela la creacion de una cuenta de usuario
func _on_cancelar_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/InicioSesion.tscn")
	
	
# Cierra la aplicacion
func _on_close_pressed() -> void:
	get_tree().quit()
	
	
# Minimiza la aplicacion
func _on_minimize_pressed() -> void:
	get_tree().root.mode = Window.MODE_MINIMIZED
	

# Muestra el texto correspondiente a la comprobacion de registro
func on_set_text_info(message: String, color: Color):
	var info_sesion = $Canvas/Panel/Margin/VBox/Margin/InfoSesion
	info_sesion.text = message
	info_sesion.modulate = color
