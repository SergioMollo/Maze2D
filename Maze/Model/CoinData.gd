extends Area2D

class_name Coin

signal collected

# Emite la señal de recoleccion de la moneda al ser alcanzada
func emit_collected_signal():
	emit_signal("collected")
