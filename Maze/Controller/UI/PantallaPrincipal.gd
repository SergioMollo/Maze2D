extends Control

@onready var player: TextureRect = $Canvas/Panel/Margin/VBox/HBox/Jugador/Panel/VBox/Player
@onready var enemy: TextureRect = $Canvas/Panel/Margin/VBox/HBox/Enemigo/Panel/VBox/Enemy

# Inica los datos cuando se instancia por primera vez
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution
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
	Singleton.selection = "player"
	get_tree().change_scene_to_file("res://Maze/View/UI/SeleccionarApariencia.tscn")


# Muestra la escena de seleccion de apariencia del enemigo
func _on_apariencia_enemigo_pressed():
	Singleton.selection = "enemy"
	get_tree().change_scene_to_file("res://Maze/View/UI/SeleccionarApariencia.tscn")
	
	
# Inicia las variables 
func initSingeltonVariables():
	Singleton.partida_reference = ""
	Singleton.nombre_partida = ""
	Singleton.move_player = false
	Singleton.move_enemy = false
	Singleton.juegos = 0
	Singleton.maze_size = Vector2i(0,0)
	
	
# Muestra las apariencias de los personajes
func setTextures():
	var texture = load(Singleton.player_texture)
	player.texture = texture
	texture = load(Singleton.enemy_texture)
	enemy.texture = texture
