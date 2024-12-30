extends Control

@onready var jugador_label: Label = $Titulo/Algoritmo2
@onready var jugador_button: OptionButton = $Opciones/AlgoritmoOptionJugador
@onready var enemigo_label: Label = $Titulo/Algoritmo1
@onready var enemigo_button: OptionButton = $Opciones/AlgoritmoOptionEnemigo
@onready var algoritmo_panel: Panel = $PanelAlgoritmo
@onready var juego_button: OptionButton = $Opciones/JuegoOption
@onready var interaccion_button: OptionButton = $Opciones/InteraccionOption
@onready var nivel_button: OptionButton = $Opciones/NivelOption


# Inica los datos cuando se instancia por primera vez
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution


# Vuelve a la pagina principal al seleccionar el boton "Atras"
func _on_atras_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


# Crea una nueva partida al presionar el boton "Crear Partida"
# 	- Crea la partida con los datos de configuración establecidos
# 	- Crea un nuevo juego y muestra la escena del laberinto
func _on_crear_partida_pressed():
	var nivel = $Opciones/NivelOption.get_selected()
	var dificultad = $Opciones/DificultadOption.get_selected()
	var modo_juego = $Opciones/JuegoOption.get_selected()
	var modo_interaccion = $Opciones/InteraccionOption.get_selected()
	var algoritmo_jugador = $Opciones/AlgoritmoOptionJugador.get_selected()
	var algoritmo_enemigo = $Opciones/AlgoritmoOptionEnemigo.get_selected()
	var juegos = $Opciones/JuegosOption.get_selected()
	
	if juegos == 0:
		juegos = 1
	elif juegos == 1:
		juegos = 3
	elif juegos == 2:
		juegos = 5
	
	
	var partida = {
		"nivel": nivel,
		"dificultad": dificultad,
		"modo_juego": modo_juego,
		"modo_interaccion": modo_interaccion,
		"estado": VideogameConstants.EstadoPartida.INICIADA,
		"numero_juegos": juegos,
		"algoritmo_jugador": algoritmo_jugador,
		"algoritmo_enemigo": algoritmo_enemigo
	}

	var new_scene = Singleton.configureGame(partida)
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
	new_scene.createGame()


# Muestra el texto informativo del modo de juego seleccionado
func _on_juego_option_item_selected(index: int) -> void:
	if index == 0:
		if interaccion_button.get_selected() == 0:
			algoritmo_panel.hide()
		hideAlgoritmo(false)
		$PanelJuego/Nombre.text = "Modo de juego: Solitario"
		$PanelJuego/Informacion.text = "El modo Solitario interactuará únicamente el jugador. 
										El objetivo será alcanzar la moneda antes de que
										finalice el tiempo estimado."
	else: 
		showAlgoritmo(false)
		$PanelJuego/Nombre.text = "Modo de juego: Enfrentamiento"
		$PanelJuego/Informacion.text = "El modo Enfrentamiento se enfrentara a un adversdario. 
										El objetivo será alcanzar la moneda evitando al 
										enemigo antes de que finalice el tiempo estimado."


# Muestra el texto informativo del modo de interaccion seleccionado
func _on_interaccion_option_item_selected(index: int) -> void:
	if index == 0:
		if juego_button.get_selected() == 0:
			algoritmo_panel.hide()
		hideAlgoritmo(true)
		$PanelInteraccion/Nombre.text = "Modo de interaccion: Usuario"
		$PanelInteraccion/Informacion.text = "El modo Usuario permite los movimientos del 
											jugador en base a entradas de teclado determinadas
											por el usuario."
	else: 
		showAlgoritmo(true)
		$PanelInteraccion/Nombre.text = "Modo de interaccion: Simulacion"
		$PanelInteraccion/Informacion.text = "El modo Simulacion permite los movimientos del 
											jugador en base a movimientos realizados por la 
											computadora en base al algoritmo determinado."


# Muestra el texto informativo del algoritmo seleccionado
func _on_algoritmo_option_item_selected(index: int) -> void:
	if index == 0:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: Anchura"
		$PanelAlgoritmo/Informacion.text = "El algoritmo en Anchura (BFS) realiza la búsqueda 
											primero en anchura, examinando todos los nodos 
											para encontrar una solución"
		
	elif index == 1:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: Profundidad"
		$PanelAlgoritmo/Informacion.text = "El algoritmo en Profundidad (DFS) realiza la búsqueda 
											primero en profundidad, examinando nodo y sus hijos 
											hasta encontrar una solución"
		
	elif index == 2:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: Dijkstra"
		$PanelAlgoritmo/Informacion.text = "El algoritmo Dijkstra determina el camino más 
											corto, examinando todos los nodos para encontrar 
											la solución"
		
	elif index == 3:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: A Estrella"
		$PanelAlgoritmo/Informacion.text = "El algoritmo A Estrella determina el camino de menor 
											coste, examinando todos los nodos para encontrar 
											una solución"


# Muestra el texto informativo del nivel seleccionado
func _on_nivel_option_item_selected(index: int) -> void:
	if index == 0:
		$PanelNivel/Nombre.text = "Tamaño: Nivel 1"
		$PanelNivel/Informacion.text = "El Nivel 1 tiene un tamaño de 15x15. 
										Recomendado para usuarios principiantes."
		
	elif index == 1:
		$PanelNivel/Nombre.text = "Tamaño: Nivel 2"
		$PanelNivel/Informacion.text = "El Nivel 2 tiene un tamaño de 25x20. 
										Recomendado para usuarios intermedios."
		
	elif index == 2:
		$PanelNivel/Nombre.text = "Tamaño: Nivel 3"
		$PanelNivel/Informacion.text = "El Nivel 3 tiene un tamaño de 50x25. 
										Recomendado para usuarios avanzados."
		
	elif index == 3:
		$PanelNivel/Nombre.text = "Tamaño: Nivel Aleatorio"
		$PanelNivel/Informacion.text = "El nivel Aleatorio tiene un tamaño comprendido 
										entre 15x15 y 50x25.
										Recomendado para usuarios de nivel intermedio-alto."


# Oculta las opciones de algoritmo para el jugador/enemigo
#  	- Oculta los algoritmos del jugador si esta en Modo Simulacion
#  	- Oculta los algoritmos del enemigo si esta en Modo Enfrentamiento
func hideAlgoritmo(player: bool):
	if player:	
		jugador_label.hide()
		jugador_button.hide()
		jugador_button.select(-1)
	else:
		enemigo_label.hide()
		enemigo_button.hide()
		enemigo_button.select(-1)
		
	
# Muestra las opciones de algoritmo para el jugador/enemigo
#  	- Muestra los algoritmos del jugador si esta en Modo Simulacion
# 	- Muestra los algoritmos del enemigo si esta en Modo Enfrentamiento
func showAlgoritmo(player: bool):
	if player:	
		jugador_label.show()
		jugador_button.show()
		jugador_button.select(0)
	else:
		enemigo_label.show()
		enemigo_button.show()
		enemigo_button.select(0)
		
	algoritmo_panel.show()
