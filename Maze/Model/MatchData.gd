extends Node

class_name Match

var id: int
var nombre: String
var nivel: VideogameConstants.Nivel
var dificultad: VideogameConstants.Dificultad
var modo_juego: VideogameConstants.ModoJuego
var modo_interaccion: VideogameConstants.ModoInteraccion
var estado: VideogameConstants.EstadoPartida
var puntuacion: float

var maze: Maze
var player: Player
var enemy: Enemy
var coin: Coin
var games = [Game]


# Asigna el identificador
func setId(value: int):
	id = value


# Asigna el nombre
func setNombre(value: String):
	nombre = value


# Asigna el nivel
func setNivel(value: VideogameConstants.Nivel):
	nivel = value


# Asigna el nivel
func setDificultad(value: VideogameConstants.Dificultad):
	dificultad = value


# Asigna el modo de juego
func setModoJuego(value: VideogameConstants.ModoJuego):
	modo_juego = value


# Asigna el modo de interaccion
func setModoInteraccion(value: VideogameConstants.ModoInteraccion):
	modo_interaccion = value


# Asigna el estado de la partida
func setEstado(value: VideogameConstants.EstadoPartida):
	estado = value


# Devuelve el identificador
func getId():
	return id


# Devuelve el nombre
func getNombre():
	return nombre


# Devuelve el nivel
func getNivel():
	return nivel


# Devuelve la dificultad
func getDificultad():
	return dificultad


# Devuelve el modo de juego
func getModoJuego():
	return modo_juego


# Devuelve el modo de interaccion
func getModoInteraccion():
	return modo_interaccion


# Devuelve el estado de la partida
func getEstado():
	return estado