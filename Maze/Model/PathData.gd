extends Node

class_name Path

var inicio: Vector2
var objetivo: Vector2
var trayectoria = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Inicializa los datos
func _init(start_node: Vector2, end_node: Vector2, trayectory: Array):
	inicio = start_node
	objetivo = end_node
	trayectoria = trayectory
