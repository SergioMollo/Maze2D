extends  Node2D

class_name Nivel1

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"xSize" : 10,
	"ySize" : 10,
	"map" : [],
	"result" : [],
	"graph" : {},
	"scale": Vector2i(512, 320),
	"initial_player_position": Vector2(48,48),
	"initial_enemy_position": Vector2(272,176),
	"initial_coin_position": Vector2(272,272)
}

func _ready():
	maze_controller.setup(level_data)
