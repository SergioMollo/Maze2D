extends Area2D

class_name CoinController

var coin

# Called when the node enters the scene tree for the first time.
func _ready():
	coin = Coin.new()  # Ruta al nodo de datos de la moneda


# Emite la señal de recoleción de la moneda cuando el jugador alcanza su posicion
func _on_body_entered(body):
	if body.name == "Jugador":
		coin.emit_collected_signal()
