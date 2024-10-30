extends  Node2D

class_name Nivel1

@onready var maze = $Maze

var level_data = {
	"xSize" : 10,
	"ySize" : 10,
	"map" : [],
	"result" : [],
	"graph" : {},
}

func _ready():
	# maze = MazeController.new()
	maze.setup(level_data)
