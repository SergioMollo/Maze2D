extends Control


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
