extends Control

@onready var jugador_label: Label = $Titulo/Algoritmo2
@onready var jugador_button: OptionButton = $Opciones/AlgoritmoOptionJugador
@onready var enemigo_label: Label = $Titulo/Algoritmo1
@onready var enemigo_button: OptionButton = $Opciones/AlgoritmoOptionEnemigo
@onready var algoritmo_panel: Panel = $PanelAlgoritmo
@onready var juego_button: OptionButton = $Opciones/JuegoOption
@onready var interaccion_button: OptionButton = $Opciones/InteraccionOption
@onready var nivel_button: OptionButton = $Opciones/NivelOption


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_atras_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


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
		"juegos": juegos,
		"algoritmo_jugador": algoritmo_jugador,
		"algoritmo_enemigo": algoritmo_enemigo
	}

	var new_scene = Singleton.configureGame(partida)
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
	new_scene.createGame()


func _on_juego_option_item_selected(index: int) -> void:
	if juego_button.get_selected() == 0:
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


func _on_interaccion_option_item_selected(index: int) -> void:
	if interaccion_button.get_selected() == 0:
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


func _on_algoritmo_option_item_selected(index: int) -> void:
	if jugador_button.get_selected() == 0:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: Anchura"
		$PanelAlgoritmo/Informacion.text = "El algoritmo en Anchura (BFS) realiza la búsqueda 
											primero en anchura, examinando todos los nodos 
											para encontrar una solución"
		
	elif jugador_button.get_selected() == 1:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: Profundidad"
		$PanelAlgoritmo/Informacion.text = "El algoritmo en Profundidad (DFS) realiza la búsqueda 
											primero en profundidad, examinando nodo y sus hijos 
											hasta encontrar una solución"
		
	elif jugador_button.get_selected() == 2:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: Dijkstra"
		$PanelAlgoritmo/Informacion.text = "El algoritmo Dijkstra determina el camino más 
											corto, examinando todos los nodos para encontrar 
											la solución"
		
	elif jugador_button.get_selected() == 3:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: A Estrella"
		$PanelAlgoritmo/Informacion.text = "El algoritmo A Estrella determina el camino de menor 
											coste, examinando todos los nodos para encontrar 
											una solución"


func _on_nivel_option_item_selected(index: int) -> void:
	if nivel_button.get_selected() == 0:
		$PanelNivel/Nombre.text = "Tamaño: Nivel 1"
		$PanelNivel/Informacion.text = "El Nivel 1 tiene un tamaño de 15x15. 
										Recomendado para usuarios principiantes."
		
	elif nivel_button.get_selected() == 1:
		$PanelNivel/Nombre.text = "Tamaño: Nivel 2"
		$PanelNivel/Informacion.text = "El Nivel 2 tiene un tamaño de 25x20. 
										Recomendado para usuarios intermedios."
		
	elif nivel_button.get_selected() == 2:
		$PanelNivel/Nombre.text = "Tamaño: Nivel 3"
		$PanelNivel/Informacion.text = "El Nivel 3 tiene un tamaño de 50x25. 
										Recomendado para usuarios avanzados."
		
	elif nivel_button.get_selected() == 3:
		$PanelNivel/Nombre.text = "Tamaño: Nivel Aleatorio"
		$PanelNivel/Informacion.text = "El nivel Aleatorio tiene un tamaño comprendido 
										entre 15x15 y 50x25.
										Recomendado para usuarios de nivel intermedio-alto."



func hideAlgoritmo(player: bool):
	
	if player:	
		jugador_label.hide()
		jugador_button.hide()
		jugador_button.select(-1)
	else:
		enemigo_label.hide()
		enemigo_button.hide()
		enemigo_button.select(-1)
		
	
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
