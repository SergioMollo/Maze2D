extends Control

var maze: MazeController
@onready var nombre: LineEdit = $Panel/VBox/Margin3/HBox/Nombre

# Called when the node enters the scene tree for the first time.
func _ready():
	nombre.text = Singleton.nombre_partida

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_guardar_pressed():
	maze.match_state = VideogameConstants.EstadoPartida.GUARDADA
	maze.game_state = VideogameConstants.EstadoJuego.EN_PAUSA
	maze.saveGame(nombre.text)
	queue_free()


func _on_cancelar_pressed():
	queue_free()


func setMaze(maze_instance: MazeController):
	maze = maze_instance
	$Panel/VBox/Margin5/HBox/Info.text = "Resultado: " + str(maze.win) + "-" + str(maze.lose) + "\n" + "Tiempo 
			restante: " + str(maze.maze.timer.time_left) + "\n"
