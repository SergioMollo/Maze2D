extends Node

class_name Database

var database: SQLite

func _ready():
	pass


func initDatabase():
	database = SQLite.new()
	database.path = "res://Database/Maze2D.db"
	database.open_db()


func closeDatabase():
	database.close_db()


func getResource():
	pass
	
	
func getItem():
	pass
	
	
func updateResource(name_collection: String, collection: Dictionary, id: String):
	database.update_rows(name_collection, "id_" + name_collection + " = " + id, collection)
	
	
func deleteResource(name_collection: String, id: String):
	database.delete_rows(name_collection, "id_" + name_collection + " = " + id)
	
	
func addResource(name_collection: String, collection: Dictionary):
	database.insert_row(name_collection, collection)
	

func getLastInsertId():
	database.query("SELECT last_insert_rowid() AS last_id")
	var last_id = ""

	for result in database.query_result:
		last_id = result["last_id"]
		print("ID de la fila insertada: ", last_id)

	return last_id
