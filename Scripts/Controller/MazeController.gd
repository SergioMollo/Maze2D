extends Node2D

class_name MazeController

var maze

var modo_juego : VideogameConstants.ModoJuego

var enemy
#var instan : EnemyController

@onready var jugador: CharacterBody2D = $"../Jugador"
@onready var agente: Node2D = $"../Jugador/AIController2D"
@onready var moneda: Area2D = $"../Moneda/Moneda2D"
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

# func _ready():
# 	maze.jugador = $Jugador
# 	maze.moneda = $Moneda/Moneda2D
# 	maze.timer = $Timer
# 	maze.tilemap = $TileMap
# 	get_window().content_scale_size = Vector2i(512, 320)
# 	#bfs()
# 	#createMap()
# 	winLabel.hide()
# 	loseLabel.hide()
# 	await get_tree().create_timer(0.0).timeout
# 	new_game() 

# func new_game():
# 	maze.jugador.maze_finished = false
# 	maze.moneda.show()
# 	winLabel.hide()
# 	loseLabel.hide()
# 	maze.jugador.position = Vector2(48,48)
# 	maze.timer.start(60)
# 	#timeLabel.text = str(timer.time_left)
# 	maze.moneda.coin.connect("collected", mostrarResultado)

# # Called every frame. 'delta' is he elapsed time since the previous frame.
# func _process(delta):
# 	if maze.jugador.maze_finished == false:
# 		timeLabel.text= str(int(maze.timer.time_left))
	
# func mostrarResultado():
# 	maze.jugador.maze_finished = true
# 	#agente.reward += 10.0
# 	print("Ha llegado al final del laberinto")
# 	winLabel.show()
# 	maze.moneda.hide()
# 	await get_tree().create_timer(5.0).timeout
# 	agente.reset()
# 	new_game()

# func _on_timer_timeout():
# 	maze.jugador.maze_finished = true
# 	print("Se ha excedido el tiempo")
# 	loseLabel.show()
# 	#agente.reward -= 1.0
# 	await get_tree().create_timer(5.0).timeout
# 	agente.reset()
# 	new_game()

func _ready():

	# Se asigna directamente hasta que se implelmente el paso de datos de configuracion inicial
	modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO

	get_window().content_scale_size = Vector2i(512, 320)
	#bfs()
	#createMap()
	winLabel.hide()
	loseLabel.hide()
	await get_tree().create_timer(0.0).timeout
	new_game()

func new_game():
	jugador.maze_finished = false
	moneda.show()
	winLabel.hide()
	loseLabel.hide()
	jugador.position = Vector2(48,48)
	
	modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO
	if modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		var enemy_scene = preload("res://Scenes/Moneda.tscn")
		enemy = enemy_scene.instantiate()
		#enemy.connect("eliminated", mostrarEliminado)
		add_sibling(enemy)
		#enemy.maze_finished = false
		enemy.position = Vector2(240,48)
		
	timer.start(60)
	#timeLabel.text = str(timer.time_left)
	moneda.coin.connect("collected", mostrarResultado)

# Called every frame. 'delta' is he elapsed time since the previous frame.
func _process(delta):
	if jugador.maze_finished == false:
		timeLabel.text= str(int(timer.time_left))
	
func mostrarResultado():
	jugador.maze_finished = true
	#agente.reward += 10.0
	print("Ha llegado al final del laberinto")
	winLabel.show()
	moneda.hide()
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	new_game()

func mostrarEliminado():
	jugador.maze_finished = true
	enemy.maze_finished = true
	print("El enemigo le ha eliminado")
	loseLabel.show()
	agente.reward -= 5.0
	# enemigoAgente.reward += 10.0
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	# enemigoAgente.reset()
	new_game()

func _on_timer_timeout():
	jugador.maze_finished = true
	print("Se ha excedido el tiempo")
	loseLabel.show()
	#agente.reward -= 1.0
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	new_game()
