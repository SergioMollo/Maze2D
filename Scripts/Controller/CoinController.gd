extends Area2D

class_name CoinController

var coin

# Called when the node enters the scene tree for the first time.
func _ready():
	coin = Coin.new()  # Ruta al nodo de datos de la moneda

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Se llama si hay colisión con el jugador
func _on_body_entered(body):
	if body.name == "Jugador":
		coin.emit_collected_signal()
