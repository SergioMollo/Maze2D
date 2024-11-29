extends Control

@onready var algoritmo_label: Label = $Algoritmo
@onready var algoritmo_button: OptionButton = $AlgoritmoOption
@onready var algoritmo_panel: Panel = $PanelAlgoritmo
@onready var juego_button: OptionButton = $JuegoOption
@onready var interaccion_button: OptionButton = $InteraccionOption
@onready var nivel_button: OptionButton = $NivelOption


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().content_scale_size = Singleton.initial_resolution

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_atras_pressed():
	get_tree().change_scene_to_file("res://Maze/View/UI/PantallaPrincipal.tscn")


func _on_crear_partida_pressed():
	var nivel = $NivelOption.get_selected()
	var dificultad = $DificultadOption.get_selected()
	var modo_juego = $JuegoOption.get_selected()
	var modo_interaccion = $InteraccionOption.get_selected()
	var algoritmo = $AlgoritmoOption.get_selected()
	var juegos = $NumeroJuegos.value

	if dificultad == 0:
		Singleton.dificultad = VideogameConstants.Dificultad.FACIL
	elif dificultad == 1:
		Singleton.dificultad = VideogameConstants.Dificultad.MEDIA
	else :
		Singleton.dificultad = VideogameConstants.Dificultad.DIFICIL

	if modo_juego == 0:
		Singleton.modo_juego = VideogameConstants.ModoJuego.MODO_SOLITARIO
	else:
		Singleton.modo_juego = VideogameConstants.ModoJuego.MODO_ENFRENTAMIENTO

	if modo_interaccion == 0:
		Singleton.modo_interaccion = VideogameConstants.ModoInteraccion.MODO_USUARIO
	else:
		Singleton.modo_interaccion = VideogameConstants.ModoInteraccion.MODO_COMPUTADORA

	Singleton.juegos = juegos

	if algoritmo == 0:
		Singleton.algoritmo = VideogameConstants.Algoritmo.BFS
	elif algoritmo == 1:
		Singleton.algoritmo = VideogameConstants.Algoritmo.DFS
	elif algoritmo == 2:
		Singleton.algoritmo = VideogameConstants.Algoritmo.DIJKSTRA
	elif algoritmo == 3:
		Singleton.algoritmo = VideogameConstants.Algoritmo.A_STAR

	if nivel == 0:
		Singleton.nivel = VideogameConstants.Nivel.NIVEL1
		get_tree().change_scene_to_file("res://Maze/View/Game/LaberintoNivel1.tscn")
	elif nivel == 1:
		Singleton.nivel = VideogameConstants.Nivel.NIVEL2
		get_tree().change_scene_to_file("res://Maze/View/Game/LaberintoNivel2.tscn")
	elif nivel == 2:
		Singleton.nivel = VideogameConstants.Nivel.NIVEL3
		get_tree().change_scene_to_file("res://Maze/View/Game/LaberintoNivel3.tscn")
	elif nivel == 3:
		Singleton.nivel = VideogameConstants.Nivel.ALEATORIO
		var information = $information
		information.text = "El nivel aleatorio aun\n no esta implementado"


func _on_juego_option_item_selected(index: int) -> void:
	if juego_button.get_selected() == 0:
		if interaccion_button.get_selected() == 0:
			hideAlgoritmo()
		$PanelJuego/Nombre.text = "Modo de juego: Solitario"
		$PanelJuego/Informacion.text = "El modo Solitario interactuará únicamente el jugador. 
										El objetivo será alcanzar la moneda antes de que
										finalice el tiempo estimado."
	else: 
		showAlgoritmo()
		$PanelJuego/Nombre.text = "Modo de juego: Enfrentamiento"
		$PanelJuego/Informacion.text = "El modo Enfrentamiento se enfrentara a un adversdario. 
										El objetivo será alcanzar la moneda evitando al 
										enemigo antes de que finalice el tiempo estimado."


func _on_interaccion_option_item_selected(index: int) -> void:
	if interaccion_button.get_selected() == 0:
		if juego_button.get_selected() == 0:
			hideAlgoritmo()
		
		$PanelInteraccion/Nombre.text = "Modo de interaccion: Usuario"
		$PanelInteraccion/Informacion.text = "El modo Usuario permite los movimientos del 
											jugador en base a entradas de teclado determinadas
											por el usuario."
	else: 
		showAlgoritmo()
		$PanelInteraccion/Nombre.text = "Modo de interaccion: Computadora"
		$PanelInteraccion/Informacion.text = "El modo Computadora permite los movimientos del 
											jugador en base a movimientos realizados por la 
											computadora en base al algoritmo determinado."


func _on_algoritmo_option_item_selected(index: int) -> void:
	if algoritmo_button.get_selected() == 0:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: BFS"
		$PanelAlgoritmo/Informacion.text = "El algoritmo BFS realiza la búsqueda primero en 
											anchura, examinando todos los nodos para encontrar 
											una solución"
		
	elif algoritmo_button.get_selected() == 1:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: DFS"
		$PanelAlgoritmo/Informacion.text = "El algoritmo DFS realiza la búsqueda primero en 
											profundidad, examinando nodo y sus hijos hasta 
											encontrar una solución"
		
	elif algoritmo_button.get_selected() == 2:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: Dijkstra"
		$PanelAlgoritmo/Informacion.text = "El algoritmo Dijkstra determina el camino más 
											corto, examinando todos los nodos para encontrar 
											la solución"
		
	elif algoritmo_button.get_selected() == 3:
		$PanelAlgoritmo/Nombre.text = "Algoritmo: A Star"
		$PanelAlgoritmo/Informacion.text = "El algoritmo A Star determina el camino de menor 
											coste, examinando todos los nodos para encontrar 
											una solución"


func _on_nivel_option_item_selected(index: int) -> void:
	if nivel_button.get_selected() == 0:
		$PanelNivel/Nombre.text = "Nivel: 1"
		$PanelNivel/Informacion.text = "El Nivel 1 tiene un tamaño de 15x15. 
										Recomendado para usuarios principiantes."
		
	elif nivel_button.get_selected() == 1:
		$PanelNivel/Nombre.text = "Nivel: 2"
		$PanelNivel/Informacion.text = "El Nivel 2 tiene un tamaño de 20x25. 
										Recomendado para usuarios intermedios."
		
	elif nivel_button.get_selected() == 2:
		$PanelNivel/Nombre.text = "Nivel: 3"
		$PanelNivel/Informacion.text = "El Nivel 3 tiene un tamaño de 50x25. 
										Recomendado para usuarios avanzados."
		
	elif nivel_button.get_selected() == 3:
		$PanelNivel/Nombre.text = "Nivel: Aleatorio"
		$PanelNivel/Informacion.text = "El nivel Aleatorio tiene un tamaño comprendido 
										entre 15x15 y 50x25.
										Recomendado para usuarios de nivel intermedio-alto."



func hideAlgoritmo():
	algoritmo_label.hide()
	algoritmo_button.hide()
	algoritmo_panel.hide()
	
	
func showAlgoritmo():
	algoritmo_label.show()
	algoritmo_button.show()	
	algoritmo_panel.show()
