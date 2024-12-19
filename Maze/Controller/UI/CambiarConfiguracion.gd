extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_guardar_pressed():
	var modo_juego = $Panel/VBox/Margin2/VBox/HBox/InteraccionOption.get_selected()
	var modo_interaccion = $Panel/VBox/Margin2/VBox/HBox2/JuegoOption.get_selected()
	var algoritmo = $Panel/VBox/Margin2/VBox/HBox3/AlgotirmoOption.get_selected()
	
	

func _on_cancelar_pressed():
	queue_free()
