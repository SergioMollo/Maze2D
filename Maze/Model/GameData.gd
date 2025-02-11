extends Node

class_name Game

var numero: int
var estado: VideogameConstants.EstadoJuego
var tiempo_restante: int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _init(time: int):
	tiempo_restante = time
	numero = 0
	estado = VideogameConstants.EstadoJuego.EN_CURSO