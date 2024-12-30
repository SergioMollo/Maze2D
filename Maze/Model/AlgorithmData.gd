extends Node

class_name Algorithm

var nombre: String
var algoritmo: VideogameConstants.Algoritmo

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

var graph = {}
var heuristic_player = {}
var heuristic_enemy = {}
var resultdfs = []

var path_jugador = []
var path_enemigo = []

var tilemap
var scene
var is_player: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
