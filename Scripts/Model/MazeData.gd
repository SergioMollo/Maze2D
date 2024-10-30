extends Node

class_name Maze

var xSize
var ySize
var map = []
var result = []
var graph = {}

var player: CharacterBody2D
var enemy: CharacterBody2D
var coin: Area2D
var tilemap: Node2D

var timer : Timer


# var panel_informacion: InformationPanel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
