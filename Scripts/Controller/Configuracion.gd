extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_save_button_pressed():
	# Aqui se modifica la resolucion y el volumen
	var volume = $Canvas/Panel/Margin/Container/Settings/Volume/VolumeSlider
	var resolution = $Canvas/Panel/Margin/Container/Settings/Resolution/ResolutionOption
	get_tree().change_scene_to_file("res://Scenes/UI/PantallaPrincipal.tscn")


func _on_back_button_pressed():
	var overlay_escene = $"."
	overlay_escene.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/PantallaPrincipal.tscn")
