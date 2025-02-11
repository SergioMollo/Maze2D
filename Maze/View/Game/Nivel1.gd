extends  Node2D

class_name Nivel1

@onready var maze_controller: Node2D = $Maze

var level_data = {
	"maze_size": Vector2i(480,480),
	"scale": Vector2i(608, 608),
	"initial_player_position": Vector2(112,112),
	"initial_enemy_position": Vector2(496,176),
	"initial_coin_position": Vector2(496,496),
	"time": 60
}

func _ready():	
	pass
	
	
func createGame():
	maze_controller.initGame(level_data)
	

# Asigna los valores de la partida cargada
# 	- Carga la partida con la configuracion recuperada
func asignValues(partida: Dictionary, jugador: Dictionary, juego: Dictionary, nivel: Dictionary, 
	enemigo: Dictionary = {}, camino_jugador: Dictionary = {}, camino_enemigo: Dictionary = {}):

	for key in level_data.keys():
		if nivel.has(key):
			level_data[key] = nivel[key]
		
	maze_controller.continuarPartida(partida, jugador, juego, level_data, enemigo, camino_jugador, camino_enemigo)
