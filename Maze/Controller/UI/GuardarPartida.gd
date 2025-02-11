extends Control

var maze_instance: MazeController

@onready var nombre: LineEdit = $Panel/VBox/Margin3/HBox/Nombre

# Inica los datos cuando se instancia por primera vez
func _ready():
	nombre.text = Videogame.nombre_partida


# Guarda los datos relevantes de la partida, asignando un nombre establecido por el usuario
func _on_guardar_pressed():
	maze_instance.maze.match_state = VideogameConstants.EstadoPartida.GUARDADA
	maze_instance.game.estado = VideogameConstants.EstadoJuego.EN_PAUSA
	maze_instance.guardarPartida(nombre.text)
	queue_free()


# Cancela el guardado de la partida, cierra el menú
func _on_cancelar_pressed():
	queue_free()


# Asigna la instancia del scrip del laberinto actual
# 	- Muestra los datos de la partida a guardar
func setMaze(instance: MazeController):
	maze_instance = instance
	$Panel/VBox/Margin5/HBox/Info.text = "Resultado: " + str(maze_instance.win) + "-" + str(maze_instance.lose) + "\n" + "Tiempo 
			restante: " + str(maze_instance.maze.timer.time_left) + "\n"
