extends Node

class_name Database

var database: SQLite


# Inica los datos cuando se instancia por primera vez
func _ready():
	pass


# Inicia la instancia de la base de datos
func initDatabase():
	database = SQLite.new()
	var path = "user://db_Maze2D.db"

	if not FileAccess.file_exists(path):
		var file = FileAccess.open("res://Database/Maze2D.db", FileAccess.READ)
		var db_copy = FileAccess.open(path, FileAccess.WRITE)
		db_copy.store_buffer(file.get_buffer(file.get_length()))
		file.close()
		db_copy.close()

	database.path = path
	database.open_db()
	createTables(database)


# Cierra la instancia de la base de datos
func closeDatabase():
	database.close_db()


# Crea las tablas en la base de datos si no existen
func createTables(db: SQLite):
	var queries = [
		"""
		CREATE TABLE IF NOT EXISTS "usuario" (
			"user"	TEXT NOT NULL UNIQUE,
			"nombre"	TEXT NOT NULL,
			"password"	TEXT NOT NULL,
			PRIMARY KEY("user")
		)
		""",
		"""
		CREATE TABLE IF NOT EXISTS camino (
			"id_camino"	TEXT NOT NULL UNIQUE,
			"inicio"	TEXT NOT NULL,
			"objetivo"	TEXT NOT NULL,
			"trayectoria"	TEXT NOT NULL,
			PRIMARY KEY("id_camino")
		)
		""",
		"""
		CREATE TABLE IF NOT EXISTS "enemigo" (
			"id_enemigo"	INTEGER NOT NULL UNIQUE,
			"posicion"	TEXT NOT NULL,
			"algoritmo"	INTEGER NOT NULL,
			"apariencia"	TEXT NOT NULL,
			"id_camino"	INTEGER NOT NULL,
			PRIMARY KEY("id_enemigo" AUTOINCREMENT)
		)
		""",
		"""
		CREATE TABLE IF NOT EXISTS "juego" (
			"id_juego"	INTEGER NOT NULL UNIQUE,
			"numero"	INTEGER NOT NULL,
			"estado"	INTEGER NOT NULL,
			"tiempo_restante"	INTEGER NOT NULL,
			PRIMARY KEY("id_juego" AUTOINCREMENT)
		)
		""",
		"""
		CREATE TABLE IF NOT EXISTS "jugador" (
			"id_jugador"	INTEGER NOT NULL UNIQUE,
			"posicion"	TEXT NOT NULL,
			"algoritmo"	INTEGER NOT NULL,
			"apariencia"	TEXT NOT NULL,
			"id_camino"	INTEGER,
			PRIMARY KEY("id_jugador" AUTOINCREMENT)
		)
		""",
		"""
		CREATE TABLE IF NOT EXISTS "nivel" (
			"id_nivel"	INTEGER NOT NULL UNIQUE,
			"nivel"	INTEGER NOT NULL,
			"maze_size"	TEXT NOT NULL,
			"scale"	TEXT NOT NULL,
			"initial_player_position"	TEXT NOT NULL,
			"initial_enemy_position"	TEXT NOT NULL,
			"initial_coin_position"	TEXT NOT NULL,
			"map"	TEXT NOT NULL,
			PRIMARY KEY("id_nivel" AUTOINCREMENT)
		)
		""",
		"""
		CREATE TABLE IF NOT EXISTS "partida" (
			"id_partida"	INTEGER NOT NULL UNIQUE,
			"nombre"	TEXT NOT NULL,
			"estado"	INTEGER NOT NULL,
			"resultado"	TEXT NOT NULL,
			"numero_juegos"	INTEGER NOT NULL,
			"modo_juego"	INTEGER NOT NULL,
			"modo_interaccion"	INTEGER NOT NULL,
			"dificultad"	INTEGER NOT NULL,
			"id_nivel"	INTEGER NOT NULL,
			"id_juego"	INTEGER NOT NULL,
			"user"	TEXT NOT NULL,
			"id_jugador"	INTEGER NOT NULL,
			"id_enemigo"	INTEGER,
			"fecha"	TEXT NOT NULL,
			PRIMARY KEY("id_partida" AUTOINCREMENT)
		)
		"""
	]
	
	for query in queries:
		db.query(query)


# Obtiene todas las partidas de un usuario
func getPartidas(user: String):
	var query = "SELECT partida.*, juego.tiempo_restante, nivel.nivel, jugador.algoritmo as algoritmo_jugador, enemigo.algoritmo as algoritmo_enemigo
	 			FROM partida 
				JOIN juego ON partida.id_juego = juego.id_juego 
				JOIN nivel ON partida.id_nivel = nivel.id_nivel
				LEFT JOIN jugador ON partida.id_jugador = jugador.id_jugador
				LEFT JOIN enemigo ON partida.id_enemigo = enemigo.id_enemigo
				WHERE user = ?
				ORDER BY partida.fecha DESC"
	database.query_with_bindings(query, [user])
	return database.query_result


# Obtiene todas las partidas de un usuario que se encuentran en estado EN_CURSO
func getPartidasEnCurso(user: String):
	var query = "SELECT partida.*, juego.tiempo_restante, nivel.nivel, jugador.algoritmo as algoritmo_jugador, enemigo.algoritmo as algoritmo_enemigo
	 			FROM partida 
				JOIN juego ON partida.id_juego = juego.id_juego 
				JOIN nivel ON partida.id_nivel = nivel.id_nivel
				LEFT JOIN jugador ON partida.id_jugador = jugador.id_jugador
				LEFT JOIN enemigo ON partida.id_enemigo = enemigo.id_enemigo
				WHERE user = ? and partida.estado = 2
				ORDER BY partida.fecha DESC"
	database.query_with_bindings(query, [user])
	return database.query_result


# Obtiene todas las partidas de un usuario que se encuentran en estado FINALIZADAS
func getPartidasFinalizadas(user: String):
	var query = "SELECT partida.*, juego.tiempo_restante, nivel.nivel, jugador.algoritmo as algoritmo_jugador, enemigo.algoritmo as algoritmo_enemigo
	 			FROM partida 
				JOIN juego ON partida.id_juego = juego.id_juego 
				JOIN nivel ON partida.id_nivel = nivel.id_nivel
				LEFT JOIN jugador ON partida.id_jugador = jugador.id_jugador
				LEFT JOIN enemigo ON partida.id_enemigo = enemigo.id_enemigo
				WHERE user = ? and partida.estado = 3
				ORDER BY partida.fecha DESC"
	database.query_with_bindings(query, [user])
	return database.query_result


# Obtiene el usuario con el user indicado
func getUser(user: String):
	var query = "SELECT * FROM usuario WHERE user = ?"
	database.query_with_bindings(query, [user])
	if database.query_result.size() != 0:
		return database.query_result[0]
	else:
		return {}


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
func updateResource(name_collection: String, collection: Dictionary, id: int):
	database.update_rows(name_collection, "id_" + name_collection + " = " + str(id), collection)
	
	
# Elimina un elemento de una tabla
func deleteResource(name_collection: String, id: String):
	database.delete_rows(name_collection, "id_" + name_collection + " = " + str(id))
	

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
