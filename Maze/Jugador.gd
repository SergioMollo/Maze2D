extends CharacterBody2D


var algoritmo

var moving = false
var maze_finished = false
var wall_collide = false
var result = []


@export var speed = 80
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
@onready var ai_controller: Node2D = $AIController2D
@onready var moneda: Area2D = $"../Moneda/Moneda2D"

var target = Vector2.ZERO
var actual_position = position

func _ready():
	position = Vector2.ZERO
	global_position = Vector2.ZERO
	set_physics_process(false)
	call_deferred("sync_frames")
	
func sync_frames():
	await get_tree().physics_frame
	set_physics_process(true)

func _physics_process(delta):
	await get_tree().physics_frame

		
