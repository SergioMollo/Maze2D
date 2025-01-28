extends Node

class_name User

var nombre: String
var user: String
var password: String


func _init(user_name: String, user_nickname: String, user_password: String) -> void:
	setNombre(user_name)
	setUser(user_nickname)
	setPassword(user_password)


# Asigna el nombre
func setNombre(value: String):
	nombre = value


# Asigna el usuario
func setUser(value: String):
	user = value


# Asigna la constraseña
func setPassword(value: String):
	password = value


# Devuelve el nombre
func getNombre():
	return nombre


# Devuelve el usuario
func getUser():
	return user


# Devuelve la contraseña
func getPassword():
	return password