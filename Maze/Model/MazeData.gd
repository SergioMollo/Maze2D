extends Node

class_name Maze

var nombre_partida: String = ""

var jugador: CharacterBody2D
var enemigo: CharacterBody2D
var moneda: Area2D
var tilemap: Node2D

var maze_size: Vector2i
var scale: Vector2i
var initial_player_position: Vector2
var initial_enemy_position: Vector2
var initial_coin_position: Vector2

var level_data: Dictionary

var timer: Timer
var time: int
var match_state: VideogameConstants.EstadoPartida


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Asigna los valores de configuracion del laberitno
func _init(level: Dictionary, player_ref: CharacterBody2D, coin_ref: Area2D, timer_ref: Timer, tilemap_ref: TileMap):
	
	level_data = level
	maze_size = level.maze_size
	scale = level.scale
	initial_player_position = level.initial_player_position
	initial_enemy_position = level.initial_enemy_position
	initial_coin_position = level.initial_coin_position
	
	jugador = player_ref
	moneda = coin_ref
	timer = timer_ref
	tilemap = tilemap_ref
	time = level_data.time
