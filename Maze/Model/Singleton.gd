extends Node

var initial_resolution: Vector2 = Vector2(1920,1080)

var player_texture = "player1.png"
var enemy_texture = "enemy1.png"

var selection = ""

var move_player = false
var move_enemy = false

var nivel: VideogameConstants.Nivel
var dificultad: VideogameConstants.Dificultad
var modo_juego: VideogameConstants.ModoJuego
var modo_interaccion: VideogameConstants.ModoInteraccion
var algoritmo: VideogameConstants.Algoritmo
var juegos: int

var maze_size: Vector2i = Vector2i(0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
