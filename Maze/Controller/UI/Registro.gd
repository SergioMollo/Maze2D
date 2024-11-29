extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution
	Singleton.connect("set_text_info", on_set_text_info)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_crear_cuenta_pressed():
	var name = $Canvas/Panel/Margin/VBox/NombreValue.text
	var email = $Canvas/Panel/Margin/VBox/EmailValue.text
	var password = $Canvas/Panel/Margin/VBox/PasswordValue.text
	var password_confirm = $Canvas/Panel/Margin/VBox/PasswordConfirmValue.text
	
	if password == password_confirm:
		Singleton.signUp(email, password, name)	


func _on_cancelar_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/InicioSesion.tscn")
	
	
func on_set_text_info(message: String, color: Color):
	var info_sesion = $Canvas/Panel/Margin/VBox/Margin/InfoSesion
	info_sesion.text = message
	info_sesion.modulate = color
