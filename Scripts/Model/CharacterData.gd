extends CharacterBody2D

class_name Character



var positionX: int
var positionY: int

var apariencia: Interface
var camino: Path

@export var speed = 320
#@export var velocity = 0



var wall_collide = false
var result = []
#var target = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
