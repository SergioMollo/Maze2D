extends Node2D

var final = false

@onready var jugador: Node2D = $Jugador
@onready var enemigo: Node2D = $Enemy
#@onready var enemigo: Node2D = $Enemy/EnemyAgent
@onready var agente: Node2D = $Jugador/AIController2D
@onready var enemigoAgente: Node2D = $Enemy/AIController2DEnemy
#@onready var enemigo2D: Area2D = $Enemy/Enemy2D
@onready var moneda: Area2D = $Moneda/Moneda2D
@onready var winLabel : Label  = $CanvasLayer/LabelWin
@onready var loseLabel : Label  = $CanvasLayer/LabelTimeExceed
@onready var infoLabel : Label  = $CanvasLayer/LabelInfo
@onready var timeLabel : Label  = $CanvasLayer/LabelTime
@onready var secondsLabel : Label  = $CanvasLayer/LabelSec
@onready var timer : Timer  = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().content_scale_size = Vector2i(992, 640)
	new_game()
	
func new_game():
	jugador.maze_finished = false
	enemigo.maze_finished = false
	moneda.show()
	winLabel.hide()
	loseLabel.hide()
	jugador.position = Vector2(80, 208)
	# enemigo.position = Vector2(80, 144)
	enemigo.position = Vector2(688, 336)
	timer.start(120)
	
	enemigo.connect("eliminated", mostrarEliminado)
	moneda.connect("collected", mostrarResultado)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if jugador.maze_finished == false:
		timeLabel.text= str(int(timer.time_left))
	pass
	
func mostrarResultado():
	jugador.maze_finished = true
	enemigo.maze_finished = true
	agente.reward += 10.0
	enemigoAgente.reward -= 10.0
	print("Ha llegado al final del laberinto")
	winLabel.show()
	moneda.hide()
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	enemigoAgente.reset()
	new_game()
	
func mostrarEliminado():
	jugador.maze_finished = true
	enemigo.maze_finished = true
	print("El enemigo le ha eliminado")
	loseLabel.show()
	agente.reward -= 5.0
	enemigoAgente.reward += 10.0
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	enemigoAgente.reset()
	new_game()
	
func _on_timer_timeout():
	jugador.maze_finished = true
	enemigo.maze_finished = true
	print("Se ha excedido el tiempo")
	loseLabel.show()
	agente.reward -= 1.0
	enemigoAgente.reward += 2.0
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	enemigoAgente.reset()
	new_game()
