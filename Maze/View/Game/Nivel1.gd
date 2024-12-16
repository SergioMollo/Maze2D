extends  Node2D

class_name Nivel1

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"maze_size": Vector2i(480,480),
	"scale": Vector2i(608, 608),
	"initial_player_position": Vector2(112,112),
	"initial_enemy_position": Vector2(496,208),
	"initial_coin_position": Vector2(496,496)
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
