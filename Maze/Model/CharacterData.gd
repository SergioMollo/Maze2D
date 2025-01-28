extends CharacterBody2D

class_name Character


var actual_position
var target = Vector2.ZERO

var moving = false
var direction = Vector2.ZERO

var apariencia: Interface
var algorithm: Algorithm
var path: Path

@export var speed = 80


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
