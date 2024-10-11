extends Node2D

var final = false

@onready var personaje: Node2D = $Personaje
@onready var agente: Node2D = $Personaje/AIController2D
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
	personaje.maze_finished = false
	moneda.show()
	winLabel.hide()
	loseLabel.hide()
	personaje.position = Vector2(80, 208)
	timer.start(120)

	#timeLabel.text = str(timer.time_left)
	moneda.connect("collected", mostrarResultado)

# Called every frame. 'delta' is   he elapsed time since the previous frame.
func _process(delta):
	timeLabel.text= str(int(timer.time_left))
	pass
	
func mostrarResultado():
	personaje.maze_finished = true
	agente.reward += 10.0
	print("Ha llegado al final del laberinto")
	winLabel.show()
	moneda.hide()
	await get_tree().create_timer(5.0).timeout
	agente.reset()
	new_game()

func _on_timer_timeout():
	personaje.maze_finished = true
	print("Se ha excedido el tiempo")
	loseLabel.show()
	agente.reward -= 1.0
	await get_tree().create_timer(1.0).timeout
	agente.reset()
	new_game()
