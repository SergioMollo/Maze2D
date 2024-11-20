extends Node

class_name Maze

var xSize
var ySize

var player: CharacterBody2D
var enemy: CharacterBody2D
var moneda: Area2D
var tilemap: Node2D
var scale: Vector2i

var initial_player_position: Vector2
var initial_enemy_position: Vector2
var initial_coin_position: Vector2

var timer : Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize_data(level_data, player_ref, coin_ref, timer_ref, tilemap_ref):
	xSize = level_data.xSize
	ySize = level_data.ySize
	scale = level_data.scale
	initial_player_position = level_data.initial_player_position
	initial_enemy_position = level_data.initial_enemy_position
	initial_coin_position = level_data.initial_coin_position
	player = player_ref
	moneda = coin_ref
	timer = timer_ref
	tilemap = tilemap_ref
	
