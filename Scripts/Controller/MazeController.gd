extends Node2D

class_name MazeController

var maze

var modo_juego : VideogameConstants.ModoJuego

@export var enemy_scene: PackedScene

@onready var player: CharacterBody2D = $"../Jugador"
@onready var agente: Node2D = $"../Jugador/AIController2D"
@onready var coin: Area2D = $"../Moneda/Moneda2D"
@onready var header : Control = $"../Layer/Header/Layer/Panel"
@onready var winLabel : Label  = $"../Layer/LabelWin"
@onready var loseLabel : Label  = $"../Layer/LabelTimeExceed"
#@onready var infoLabel : Label  = $"../Control/CanvasLayer/Panel/LabelInfo"
@onready var timeLabel : Label  = $"../Layer/Header/Layer/Panel/Container/Time/ValueTime/LabelTime"
#@onready var secondsLabel : Label  = $"../Control/CanvasLayer/Panel/LabelSec"
@onready var timer : Timer  = $"../Timer"
@onready var tilemap = $"../TileMap"


func setup(level_data : Dictionary):
	maze = Maze.new()
	maze.initialize_data(level_data, player, coin, timer, tilemap)
	maze.moneda.coin.connect("collected", mostrarResultado)
	get_window().content_scale_size = maze.scale
	header.size = Vector2(maze.scale.x,64)

func _ready():
	# Se asigna directamente hasta que se implelmente el paso de datos de configuracion inicial
	modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO
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

	maze.player.createMap(maze.xSize, maze.ySize)

	# Provisional hasta configurar datos y pasarlo
	modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO
	if modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		spawnEnemy()
		maze.player.createHeuristic(maze.xSize, maze.ySize, maze.enemy.position)
	
	# var result_bfs = player.bfsMaze(maze.player.position, maze.initial_coin_position)
	# var result_dfs = player.dfsMaze(maze.player.position, maze.initial_coin_position)
	# var result_dijkstra = maze.player.dijkstraMaze(maze.player.position, maze.initial_coin_position)
	# var result_a_star = maze.player.aStarMaze(maze.player.position, maze.initial_coin_position)
		
	maze.timer.start(60)
	timeLabel.text = str(timer.time_left)

# Called every frame. 'delta' is he elapsed time since the previous frame.
func _process(delta):
	if maze.player.maze_finished == false:
		timeLabel.text= str(int(maze.timer.time_left))
	

func spawnEnemy():
	maze.enemy = enemy_scene.instantiate()
	maze.enemy.position = maze.initial_enemy_position
	maze.enemy.connect("eliminated", mostrarEliminado)
	maze.enemy.maze_finished = false
	get_parent().add_child(maze.enemy)


func mostrarResultado():
	maze.player.maze_finished = true
	maze.enemy.maze_finished = true
	# agente.reward += 10.0
	# enemigoAgente.reward -= 10.0
	print("Ha llegado al final del laberinto")
	winLabel.show()
	maze.enemy.queue_free() 
	maze.moneda.hide()
	await get_tree().create_timer(5.0).timeout
	# agente.reset()
	# enemigoAgente.reset()
	new_game()

func mostrarEliminado():
	maze.player.maze_finished = true
	maze.enemy.maze_finished = true
	print("El enemigo le ha eliminado")
	loseLabel.show()
	maze.enemy.queue_free() 
	# agente.reward -= 5.0
	# enemigoAgente.reward += 10.0
	await get_tree().create_timer(5.0).timeout
	# agente.reset()
	# enemigoAgente.reset()
	new_game()

func _on_timer_timeout():
	maze.player.maze_finished = true
	maze.enemy.maze_finished = true
	print("Se ha excedido el tiempo")
	loseLabel.show()
	maze.enemy.queue_free()
	# agente.reward -= 1.0
	# enemigoAgente.reward += 2.0
	await get_tree().create_timer(5.0).timeout
	# agente.reset()
	# enemigoAgente.reset()
	new_game()
