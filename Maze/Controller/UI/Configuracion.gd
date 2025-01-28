extends Control

var bus_index = AudioServer.get_bus_index("Master")
var volume_value

# Called when the node enters the scene tree for the first time.
func _ready():
	var volume = $Canvas/Panel/Margin/Container/Settings/Volume/VolumeSlider
	var resolution = $Canvas/Panel/Margin/Container/Settings/Resolution/ResolutionOption
	
	volume_value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	volume.value = volume_value
	
	var resolution_value = get_window().size
	var resolution_text = str(resolution_value.x) + "x" + str(resolution_value.y)
	if resolution_text == "1920x1080":
		resolution.selected = 0
	elif resolution_text == "1280x720":
		resolution.selected = 1
	elif resolution_text == "960x540":
		resolution.selected = 2
	elif resolution_text == "640x480":
		resolution.selected = 3


func _on_save_button_pressed():
	var volume = $Canvas/Panel/Margin/Container/Settings/Volume/VolumeSlider
	var resolution = $Canvas/Panel/Margin/Container/Settings/Resolution/ResolutionOption
	
	var values = resolution.get_item_text(resolution.get_selected()).split("x")
	get_window().size = Vector2(int(values[0]), int(values[1]))
	
	var overlay_escene = $"."
	overlay_escene.queue_free()


func _on_back_button_pressed():
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume_value))
	var overlay_escene = $"."
	overlay_escene.queue_free()


func _on_volume_slider_value_changed(value: float) -> void:
	var volume = $Canvas/Panel/Margin/Container/Settings/Volume/VolumeSlider
	
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(volume.value)
	)
	
	
