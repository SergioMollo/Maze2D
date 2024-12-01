extends Node

class_name VideogameConstants

enum EstadoJuego{ EN_CURSO, EN_PAUSA, FINALIZADO }

enum EstadoPartida{ INICIADA, EN_CURSO, GUARDADA, FINALIZADA }

enum Algoritmo{ BFS, DFS, A_STAR, DIJKSTRA, EMPTY }

enum Nivel { NIVEL1, NIVEL2, NIVEL3, ALEATORIO }

enum ModoInteraccion { MODO_USUARIO, MODO_COMPUTADORA }

enum ModoJuego { MODO_SOLITARIO, MODO_ENFRENTAMIENTO }

enum Resultado { VICTORIA, DERROTA, EMPATE }

enum Dificultad { FACIL, MEDIA, DIFICIL }

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
