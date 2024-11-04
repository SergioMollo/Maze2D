extends Node2D

class_name MazeController

var maze

var modo_juego : VideogameConstants.ModoJuego

@export var enemy_scene: PackedScene

@onready var player: CharacterBody2D = $"../Jugador"
@onready var agente: Node2D = $"../Jugador/AIController2D"
@onready var coin: Area2D = $"../Moneda/Moneda2D"
@onready var winLabel : Label  = $"../CanvasLayer/LabelWin"
@onready var loseLabel : Label  = $"../CanvasLayer/LabelTimeExceed"
@onready var infoLabel : Label  = $"../CanvasLayer/LabelInfo"
@onready var timeLabel : Label  = $"../CanvasLayer/LabelTime"
@onready var secondsLabel : Label  = $"../CanvasLayer/LabelSec"
@onready var timer : Timer  = $"../Timer"
@onready var tilemap = $"../TileMap"

func setup(level_data : Dictionary):
	maze = Maze.new()
	maze.xSize = level_data.xSize
	maze.ySize = level_data.ySize
	maze.map = level_data.map
	maze.result = level_data.result
	maze.graph = level_data.graph
	maze.scale = level_data.scale
	maze.initial_player_position = level_data.initial_player_position
	maze.initial_enemy_position = level_data.initial_enemy_position
	maze.initial_coin_position = level_data.initial_coin_position
	maze.player = player
	maze.moneda = coin
	maze.timer = timer
	maze.tilemap = tilemap
	maze.moneda.coin.connect("collected", mostrarResultado)
	get_window().content_scale_size = maze.scale

func _ready():
	#maze = Maze.new()

	
	# Se asigna directamente hasta que se implelmente el paso de datos de configuracion inicial
	modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO

	#bfs()
	#createMap()
	winLabel.hide()
	loseLabel.hide()
	await get_tree().create_timer(0.0).timeout
	new_game()

func new_game():
	maze.player.maze_finished = false
	maze.moneda.show()
	winLabel.hide()
	loseLabel.hide()
	maze.player.position = maze.initial_player_position
	maze.moneda.coin.position = maze.initial_coin_position
	
	modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO
	if modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		#var enemy_scene = preload("res://Scenes/Enemy.tscn")
		maze.enemy = enemy_scene.instantiate()
		maze.enemy.position = maze.initial_enemy_position
		#maze.enemy.global_position = Vector2(240,48)
		maze.enemy.connect("eliminated", mostrarEliminado)
		maze.enemy.maze_finished = false
		get_parent().add_child(maze.enemy)
		
		
		
	maze.timer.start(60)
	timeLabel.text = str(timer.time_left)

# Called every frame. 'delta' is he elapsed time since the previous frame.
func _process(delta):
	if maze.player.maze_finished == false:
		timeLabel.text= str(int(maze.timer.time_left))
	
func mostrarResultado():
	maze.player.maze_finished = true
	#agente.reward += 10.0
	print("Ha llegado al final del laberinto")
	winLabel.show()
	maze.moneda.hide()
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	new_game()

func mostrarEliminado():
	maze.player.maze_finished = true
	maze.enemy.maze_finished = true
	print("El enemigo le ha eliminado")
	loseLabel.show()
	maze.enemy.queue_free() 
	agente.reward -= 5.0
	# enemigoAgente.reward += 10.0
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	# enemigoAgente.reset()
	new_game()

func _on_timer_timeout():
	maze.player.maze_finished = true
	print("Se ha excedido el tiempo")
	loseLabel.show()
	#agente.reward -= 1.0
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	new_game()
