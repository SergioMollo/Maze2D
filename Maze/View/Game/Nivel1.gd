extends  Node2D

class_name Nivel1

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"xSize" : 320,
	"ySize" : 320,
	"scale": Vector2i(448, 448),
	"initial_player_position": Vector2(112,112),
	"initial_enemy_position": Vector2(336,240),
	"initial_coin_position": Vector2(336,336)
}

func _ready():	
	maze_controller.setup(level_data)
