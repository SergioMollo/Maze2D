extends Control

var player_textures = ["player1.png", "player2.png", "player3.png", "player4.png"]
var enemy_textures = ["enemy1.png", "enemy2.png", "enemy3.png", "enemy4.png"]
var index = 0

@onready var imagen = $Panel/Imagen

# Inica los datos cuando se instancia por primera vez
func _ready():
	get_window().content_scale_size = Videogame.initial_resolution
	
	var texture
	if Videogame.selection == "player":
		texture = load(Videogame.player_texture)
		index = player_textures.find(Videogame.player_texture)
	elif Videogame.selection == "enemy":	
		texture = load(Videogame.enemy_texture)
		index = enemy_textures.find(Videogame.enemy_texture)
	
	imagen.texture = texture


# Muestra la siguiente apariencia al presionar el boton derecho
func _on_left_pressed():
	var texture
	
	if Videogame.selection == "player":
		if index == 0:
			index = player_textures.size()-1
			texture = load("res://Resources/Pixelart/" + player_textures[index])
		else:
			index -= 1
			texture = load("res://Resources/Pixelart/" + player_textures[index])
	elif Videogame.selection == "enemy":
		if index == 0:
			index = enemy_textures.size()-1
			texture = load("res://Resources/Pixelart/" + enemy_textures[index])
			
		else:
			index -= 1
			texture = load("res://Resources/Pixelart/" + enemy_textures[index])
	
	imagen.texture = texture


# Muestra la siguiente apariencia al presionar el boton izquierdo
func _on_rigth_pressed():
	var texture
	
	if Videogame.selection == "player":
		if index == player_textures.size()-1:
			index = 0
			texture = load("res://Resources/Pixelart/" + player_textures[index])			
		else:
			index += 1
			texture = load("res://Resources/Pixelart/" + player_textures[index])
	elif Videogame.selection == "enemy":
		if index == enemy_textures.size()-1:
			index = 0
			texture = load("res://Resources/Pixelart/" + enemy_textures[index])
		else:
			index += 1
			texture = load("res://Resources/Pixelart/" + enemy_textures[index])
	
	imagen.texture = texture
	

# Asigna la apariencia seleccionada al jugador/enemigo
func _on_seleccionar_pressed():
	
	if Videogame.selection == "player":
		Videogame.player_texture = imagen.texture.resource_path
	elif Videogame.selection == "enemy":
		Videogame.enemy_texture = imagen.texture.resource_path
	
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


# Cancela la asignación de apariencia al jugador/enemigo
func _on_cancelar_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")
