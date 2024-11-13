extends  Node2D

class_name Nivel2

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"xSize" : 800,
	"ySize" : 640,
	"map" : [],
	"result" : [],
	"graph" : {},
	"scale": Vector2i(992, 704),
	"initial_player_position": Vector2(144,208),
	"initial_enemy_position": Vector2(304,304),
	"initial_coin_position": Vector2(560,432)
}

func _ready():
	maze_controller.setup(level_data)
