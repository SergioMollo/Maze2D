extends Control

@onready var panel_jugador: HBoxContainer = $Panel/VBox/Margin2/VBox/HBox2
@onready var panel_enemigo: HBoxContainer = $Panel/VBox/Margin2/VBox/HBox4
@onready var jugador_button: OptionButton = $Panel/VBox/Margin2/VBox/HBox2/AlgotirmoOption
@onready var enemigo_button: OptionButton = $Panel/VBox/Margin2/VBox/HBox4/AlgotirmoOption

var maze: MazeController

# Inica los datos cuando se instancia por primera vez
func _ready():
	initOptions()

# Obtiene los datos de configuracion modificados y los guarda
# 	- Reinicia el juego con la nueva configuración
func _on_guardar_pressed():
	var modo_interaccion = $Panel/VBox/Margin2/VBox/HBox/InteraccionOption.get_selected()
	var modo_juego = $Panel/VBox/Margin2/VBox/HBox3/JuegoOption.get_selected()
	var jugador = $Panel/VBox/Margin2/VBox/HBox2/AlgotirmoOption.get_selected()
	var enemigo = $Panel/VBox/Margin2/VBox/HBox4/AlgotirmoOption.get_selected()
	
	if modo_juego == 0:
		Singleton.modo_juego = VideogameConstants.ModoJuego.MODO_SOLITARIO
	else:
		Singleton.modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO
		
	if modo_interaccion == 0:
		Singleton.modo_interaccion = VideogameConstants.ModoInteraccion.MODO_USUARIO
	else:
		Singleton.modo_interaccion = VideogameConstants.ModoInteraccion.MODO_SIMULACION
	
	if jugador == 0:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.BFS
	elif jugador == 1:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.DFS
	elif jugador == 2:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.DIJKSTRA
	elif jugador == 3:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.A_STAR
	elif jugador == -1:
		Singleton.algoritmo_jugador = VideogameConstants.Algoritmo.EMPTY	
		
	if enemigo == 0:
		Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.BFS
	elif enemigo == 1:
		Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.DFS
	elif enemigo == 2:
		Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.DIJKSTRA
	elif enemigo == 3:
		Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.A_STAR
	elif enemigo == -1:
		Singleton.algoritmo_enemigo = VideogameConstants.Algoritmo.EMPTY
	
	maze.time_left = maze.maze.time
	maze.game_number -= 1
	maze.initiate = false
	queue_free()
	maze.new_game()


# Cancela el cambio y cierra el menu
func _on_cancelar_pressed():
	queue_free()


#  Muestra/Oculta el algoritmo segun el indice de la opcion de modo de interaccion seleccionada
func _on_interaccion_option_item_selected(index: int) -> void:
	if index == 1:
		showAlgoritmo(true)
	else:
		hideAlgoritmo(true)


#  Muestra/Oculta el algoritmo segun el indice de la opcion de modo de juego seleccionada
func _on_juego_option_item_selected(index: int) -> void:
	if index == 1:
		showAlgoritmo(false)
	else:
		hideAlgoritmo(false)
	
	
# Oculta el algoritmo segun el tipo de modo seleccionado
# 	- Establece la opcion a una indefinida
func hideAlgoritmo(player: bool):
	
	if player:	
		panel_jugador.hide()
		jugador_button.select(-1)
	else:
		panel_enemigo.hide()
		enemigo_button.select(-1)
		

# Oculta el algoritmo segun el tipo de modo seleccionado
# 	- Establece la opcion a la primera opcion disponible
func showAlgoritmo(player: bool):
	if player:	
		panel_jugador.show()
		jugador_button.select(0)
	else:
		panel_enemigo.show()
		enemigo_button.select(0)


# Inicia y muestra las opciones de configuracion actuales
func initOptions():

	if Singleton.modo_interaccion == VideogameConstants.ModoInteraccion.MODO_SIMULACION:
		showAlgoritmo(true)
		$Panel/VBox/Margin2/VBox/HBox/InteraccionOption.select(1)

	if Singleton.modo_juego == VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO:
		showAlgoritmo(false)
		$Panel/VBox/Margin2/VBox/HBox3/JuegoOption.select(1)

# Asigna la instancia del scrip del laberinto actual
func setMaze(maze_instance: MazeController):
	maze = maze_instance
