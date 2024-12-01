extends  Node2D

class_name Aleatorio

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"maze_size": Vector2i(1600,800),
	"scale": Vector2i(1792, 800),
	"initial_player_position": Vector2(112,304),
	"initial_enemy_position": Vector2(816,400),
	"initial_coin_position": Vector2(1296,112)
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
