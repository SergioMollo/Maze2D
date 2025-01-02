extends Control

@onready var player: TextureRect = $Canvas/Panel/Margin/VBox/HBox/Jugador/Panel/VBox/Player
@onready var enemy: TextureRect = $Canvas/Panel/Margin/VBox/HBox/Enemigo/Panel/VBox/Enemy

# Inica los datos cuando se instancia por primera vez
func _ready():
	get_window().content_scale_size = Videogame.initial_resolution
	$Canvas/Panel/Margin/VBox/HBox/VBox/CrearPartida.grab_focus()
	initSingeltonVariables()
	setTextures()
	

# Muestra la escena de Crear Partida
func _on_crear_partida_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/CrearPartida.tscn")


# Muestra la escena de Continuar Partida
func _on_continuar_partida_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/ContinuarPartida.tscn")


# Muestra la escena de Configuracion
func _on_ajustes_pressed():
	var overlay_scene = preload("res://Maze/View/UI/Configuracion.tscn")
	var node = $"."
	node.modulate.a = 0.5
	var instance = overlay_scene.instantiate()
	add_child(instance)

	
# Cierra la aplicacion
func _on_salir_pressed():
	get_tree().quit()


# Muestra la escena de seleccion de apariencia del jugador
func _on_apariencia_jugador_pressed():
	Videogame.selection = "player"
	get_tree().change_scene_to_file("res://Maze/View/UI/SeleccionarApariencia.tscn")


# Muestra la escena de seleccion de apariencia del enemigo
func _on_apariencia_enemigo_pressed():
	Videogame.selection = "enemy"
	get_tree().change_scene_to_file("res://Maze/View/UI/SeleccionarApariencia.tscn")
	
	
# Inicia las variables 
func initSingeltonVariables():
	Videogame.move_player = false
	Videogame.move_enemy = false
	Videogame.juegos = 0
	Videogame.maze_size = Vector2i(0,0)
	
	
# Muestra las apariencias de los personajes
func setTextures():
	var texture = load(Videogame.player_texture)
	player.texture = texture
	texture = load(Videogame.enemy_texture)
	enemy.texture = texture
