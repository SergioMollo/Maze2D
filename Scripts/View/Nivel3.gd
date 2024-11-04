extends  Node2D

class_name Nivel3

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"xSize" : 1600,
	"ySize" : 800,
	"map" : [],
	"result" : [],
	"graph" : {},
	"scale": Vector2i(1792, 800),
	"initial_player_position": Vector2(104,368),
	"initial_enemy_position": Vector2(968,352),
	"initial_coin_position": Vector2(1288,112)
}

func _ready():
	maze_controller.setup(level_data)
