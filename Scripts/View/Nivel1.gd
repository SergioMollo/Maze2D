extends  Node2D

class_name Nivel1

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"xSize" : 320,
	"ySize" : 320,
	"map" : [],
	"result" : [],
	"graph" : {},
	"scale": Vector2i(512, 384),
	"initial_player_position": Vector2(144,112),
	"initial_enemy_position": Vector2(368,240),
	"initial_coin_position": Vector2(368,336)
}

func _ready():
	maze_controller.setup(level_data)
