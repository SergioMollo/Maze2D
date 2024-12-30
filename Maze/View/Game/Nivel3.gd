extends  Node2D

class_name Nivel3

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"maze_size": Vector2i(1600,800),
	"scale": Vector2i(1728, 928),
	"initial_player_position": Vector2(112,304),
	"initial_enemy_position": Vector2(880,464),
	"initial_coin_position": Vector2(1360,176),
	"time": 180
}

func _ready():	
	pass
	
	
	
func createGame():
	maze_controller.initGame(level_data)


func asignValues(partida: Dictionary, jugador: Dictionary, juego: Dictionary, moneda: Dictionary, 
	enemigo: Dictionary = {}, camino_jugador: Dictionary = {}, camino_enemigo: Dictionary = {}):
	
	for key in partida.keys():
		level_data[key] = partida[key]
		
	maze_controller.reloadGame(level_data, jugador, enemigo, juego, moneda, camino_jugador, camino_enemigo)
