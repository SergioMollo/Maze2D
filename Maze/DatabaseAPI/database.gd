extends Node

class_name Database

var database: SQLite


# Inica los datos cuando se instancia por primera vez
func _ready():
	pass


# Inicia la instancia de la base de datos
func initDatabase():
	database = SQLite.new()
	database.path = "res://Database/Maze2D.db"
	database.open_db()


# Cierra la instancia de la base de datos
func closeDatabase():
	database.close_db()


# Obtiene todas las partidas de un usuario
func getPartidas(email: String):
	var query = "SELECT partida.*, juego.tiempo_restante, jugador.algoritmo as algoritmo_jugador, enemigo.algoritmo as algoritmo_enemigo
	 			FROM partida 
				JOIN juego ON partida.id_juego = juego.id_juego 
				JOIN jugador ON jugador.id_jugador = jugador.id_jugador
				WHERE email_usuario = ?"
	database.query_with_bindings(query, [email])
	return database.query_result


# Obtiene todas las partidas de un usuario
func getPartidasEnCurso(email: String):
	var query = "SELECT partida.*, juego.tiempo_restante, nivel.nivel, jugador.algoritmo as algoritmo_jugador, enemigo.algoritmo as algoritmo_enemigo
	 			FROM partida 
				JOIN juego ON partida.id_juego = juego.id_juego 
				JOIN nivel ON partida.id_nivel = nivel.id_nivel
				LEFT JOIN jugador ON partida.id_jugador = jugador.id_jugador
				LEFT JOIN enemigo ON partida.id_enemigo = enemigo.id_enemigo
				WHERE email_usuario = ? and partida.estado = 2"
	database.query_with_bindings(query, [email])
	return database.query_result


# Obtiene todas las partidas de un usuario
func getPartidasFinalizadas(email: String):
	var query = "SELECT partida.*, juego.tiempo_restante, nivel.nivel, jugador.algoritmo as algoritmo_jugador, enemigo.algoritmo as algoritmo_enemigo
	 			FROM partida 
				JOIN juego ON partida.id_juego = juego.id_juego 
				JOIN nivel ON partida.id_nivel = nivel.id_nivel
				LEFT JOIN jugador ON partida.id_jugador = jugador.id_jugador
				LEFT JOIN enemigo ON partida.id_enemigo = enemigo.id_enemigo
				WHERE email_usuario = ? and partida.estado = 3"
	database.query_with_bindings(query, [email])
	return database.query_result


# Obtiene uel usuario con el email indicado
func getUser(email: String):
	var query = "SELECT * FROM usuario WHERE email = ?"
	database.query_with_bindings(query, [email])
	return database.query_result


# Obtiene una partida concreta
func getPartida(id: int):
	var query = "SELECT * FROM partida WHERE id_partida = ?"
	database.query_with_bindings(query, [id])
	return database.query_result[0]


# Obtiene un juego concreto
func getJuego(id: int):
	var query = "SELECT * FROM juego WHERE id_juego = ?"
	database.query_with_bindings(query, [id])
	return database.query_result[0]


# Obtiene un jugador concreto
func getJugador(id: int):
	var query = "SELECT * FROM jugador WHERE id_jugador = ?"
	database.query_with_bindings(query, [id])
	return database.query_result[0]


# Obtiene un nivel concreto
func getNivel(id: int):
	var query = "SELECT * FROM nivel WHERE id_nivel = ?"
	database.query_with_bindings(query, [id])
	return database.query_result[0]


# Obtiene un camino concreto
func getCamino(id: int):
	var query = "SELECT * FROM camino WHERE id_camino = ?"
	database.query_with_bindings(query, [id])
	return database.query_result[0]


# Obtiene un enemigo concreto
func getEnemigo(id: int):
	var query = "SELECT * FROM enemigo WHERE id_enemigo = ?"
	database.query_with_bindings(query, [id])
	return database.query_result[0]
	
	
# Actualiza un elemento de una tabla
func updateResource(name_collection: String, collection: Dictionary, id: String):
	database.update_rows(name_collection, "id_" + name_collection + " = " + id, collection)
	
	
# Elimina un elemento de una tabla
func deleteResource(name_collection: String, id: String):
	database.delete_rows(name_collection, "id_" + name_collection + " = " + id)
	

# Añade un elemento de una tabla
func addResource(name_collection: String, collection: Dictionary):
	database.insert_row(name_collection, collection)
	

# Obtiene el identificador del un elemento insertado
func getLastInsertId():
	database.query("SELECT last_insert_rowid() AS last_id")
	var last_id = ""

	for result in database.query_result:
		last_id = result["last_id"]

	return last_id
