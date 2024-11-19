extends Node

class_name Match

var id: int
var nombre: String
var nivel: VideogameConstants.Nivel
var modo_juego: VideogameConstants.ModoJuego
var modo_interaccion: VideogameConstants.ModoInteraccion
var estado: VideogameConstants.EstadoPartida
var puntuacion: float

var maze: Maze
var player: Player
var enemy: Enemy
var coin: Coin
var games = [Game]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
