extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_configuration_pressed():
	var overlay_scene = preload("res://Scenes/UI/GameOptions.tscn")
	var instance = overlay_scene.instantiate()
	add_child(instance)
	instance.position = Vector2(288,288)
	#instance.rect_size = Vector2(200,200)


func _on_pause_pressed():
	pass # Replace with function body.
