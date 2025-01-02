extends Node

class_name Algorithm

var nombre: String
var algoritmo: VideogameConstants.Algoritmo

var graph = {}
var heuristic_player = {}
var heuristic_enemy = {}

var path_jugador = []
var path_enemigo = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _init(algorithm: VideogameConstants.Algoritmo, nombre_algoritmo: String, initial_graph: Dictionary):
	nombre = nombre_algoritmo
	algoritmo = algorithm
	graph = initial_graph
