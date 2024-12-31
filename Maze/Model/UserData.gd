extends Node

class_name User

var nombre: String
var email: String
var password: String


# Asigna el nombre
func setNombre(value: String):
	nombre = value


# Asigna el email
func setEmail(value: String):
	email = value


# Asigna la constraseña
func setPassword(value: String):
	password = value


# Devuelve el nombre
func getNombre():
	return nombre


# Devuelve el email
func getEmail():
	return email


# Devuelve la contraseña
func getPassword():
	return password