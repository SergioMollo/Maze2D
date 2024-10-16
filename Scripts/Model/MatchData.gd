extends Node

class_name Match

var id: int
var nombre: String
var nivel: GameConstants.Nivel
var modo_juego: GameConstants.ModoJuego
var modo_interaccion: GameConstants.ModoInteraccion
var estado: GameConstants.EstadoPartida
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
