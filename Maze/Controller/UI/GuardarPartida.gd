extends Control

var maze: MazeController
@onready var nombre: LineEdit = $Panel/VBox/Margin3/HBox/Nombre

# Inica los datos cuando se instancia por primera vez
func _ready():
	nombre.text = Singleton.nombre_partida


# Guarda los datos relevantes de la partida, asignando un nombre establecido por el usuario
func _on_guardar_pressed():
	maze.match_state = VideogameConstants.EstadoPartida.GUARDADA
	maze.game_state = VideogameConstants.EstadoJuego.EN_PAUSA
	maze.saveGame(nombre.text)
	queue_free()


# Cancela el guardado de la partida, cierra el menú
func _on_cancelar_pressed():
	queue_free()


# Asigna la instancia del scrip del laberinto actual
# 	- Muestra los datos de la partida a guardar
func setMaze(maze_instance: MazeController):
	maze = maze_instance
	$Panel/VBox/Margin5/HBox/Info.text = "Resultado: " + str(maze.win) + "-" + str(maze.lose) + "\n" + "Tiempo 
			restante: " + str(maze.maze.timer.time_left) + "\n"
