extends Control

var player_textures = ["player1.png", "player2.png", "player3.png", "player4.png"]
var enemy_textures = ["enemy1.png", "enemy2.png", "enemy3.png", "enemy4.png"]
var index = 0

@onready var imagen = $Panel/Imagen

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var texture
	if Singleton.selection == "player":
		texture = load("res://Resources/PixelArt/" + Singleton.player_texture)
		index = player_textures.find(Singleton.player_texture)
	elif Singleton.selection == "enemy":	
		texture = load("res://Resources/PixelArt/" + Singleton.enemy_texture)
		index = enemy_textures.find(Singleton.enemy_texture)
	
	imagen.texture = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_left_pressed():
	var texture
	
	if Singleton.selection == "player":
		if index == 0:
			index = player_textures.size()-1
			texture = load("res://Resources/PixelArt/" + player_textures[index])
		else:
			index -= 1
			texture = load("res://Resources/PixelArt/" + player_textures[index])
	elif Singleton.selection == "enemy":
		if index == 0:
			index = enemy_textures.size()-1
			texture = load("res://Resources/PixelArt/" + enemy_textures[index])
			
		else:
			index -= 1
			texture = load("res://Resources/PixelArt/" + enemy_textures[index])
	
	imagen.texture = texture


func _on_rigth_pressed():
	var texture
	
	if Singleton.selection == "player":
		if index == player_textures.size()-1:
			index = 0
			texture = load("res://Resources/PixelArt/" + player_textures[index])			
		else:
			index += 1
			texture = load("res://Resources/PixelArt/" + player_textures[index])
	elif Singleton.selection == "enemy":
		if index == enemy_textures.size()-1:
			index = 0
			texture = load("res://Resources/PixelArt/" + enemy_textures[index])
		else:
			index += 1
			texture = load("res://Resources/PixelArt/" + enemy_textures[index])
	
	imagen.texture = texture
	

func _on_seleccionar_pressed():
	
	if Singleton.selection == "player":
		Singleton.player_texture = imagen.texture
	elif Singleton.selection == "enemy":
		Singleton.enemy_texture = imagen.texture
	
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_cancelar_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")
