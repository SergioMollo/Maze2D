extends  Node2D

class_name Nivel1

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"xSize" : 320,
	"ySize" : 320,
	"map" : [],
	"result" : [],
	"graph" : {},
	"scale": Vector2i(576, 576),
	"initial_player_position": Vector2(176,208),
	"initial_enemy_position": Vector2(400,336),
	"initial_coin_position": Vector2(400,432)
}

func _ready():
	maze_controller.setup(level_data)
