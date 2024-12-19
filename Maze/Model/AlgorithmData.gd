extends Node

class_name Algorithm

var nombre: String
var algoritmo: VideogameConstants.Algoritmo

const pixels_move = 32
const pixels_offset = 64
const pixels_center = 16

var graph = {}
var heuristic = {}
var resultdfs = []

var tilemap
var scene
var is_player


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
