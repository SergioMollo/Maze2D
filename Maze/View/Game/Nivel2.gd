extends  Node2D

class_name Nivel2

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"xSize" : 800,
	"ySize" : 640,
	"scale": Vector2i(928, 768),
	"initial_player_position": Vector2(112,208),
	"initial_enemy_position": Vector2(272,304),
	"initial_coin_position": Vector2(528,432)
}

func _ready():
	maze_controller.setup(level_data)
