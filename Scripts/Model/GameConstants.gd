extends Node

class_name GameConstants

enum EstadoJuego{ INICIADO, EN_CURSO, EN_PAUSA, FINALIZADO }

enum EstadoPartida{ INICIADA, GUARDADA, FINALIZADA }

enum Algoritmo{ BFS, DFS, A_STAR, DIJKSTRA }

enum Nivel { NIVEL1, NIVEL2, NIVEL3, ALEATORIO }

enum ModoInteraccion { MODO_USUARIO, MODO_COMPUTADORA }

enum ModoJuego { MODO_SOLITARIO, MODO_ENFRENTAMIENTO }

enum Resultado { EN_JUEGO, VICTORIA, DERROTA }

# enum Dificultad { FACIL, MEDIA, DIFICIL }


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
