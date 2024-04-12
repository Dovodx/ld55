extends Control

#TODO: remember between runs of game
#TODO: highlight sensitivity text when clicked

func _ready():
	$"mouse sensitivity textedit".text = str(Global.mouse_sensitivity)
	$"mouse sensitivity slider".value = Global.mouse_sensitivity
	$"master volume slider".value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$"sfx volume slider".value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$"music volume slider".value = db_to_linear(AudioServer.get_bus_volume_db(2))

func _on_mouse_sensitivity_textedit_text_changed():
	if $"mouse sensitivity textedit".text.is_valid_float():
		Global.mouse_sensitivity = $"mouse sensitivity textedit".text.to_float()
		$"mouse sensitivity slider".value = Global.mouse_sensitivity
	else:
		$"mouse sensitivity textedit".text = str(Global.mouse_sensitivity)

func _on_mouse_sensitivity_slider_value_changed(value):
	Global.mouse_sensitivity = value
	$"mouse sensitivity textedit".text = str(value)


func _on_master_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_sfx_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func _on_music_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))


func _on_toggle_fullscreen_button_pressed():
	Global.toggle_fullscreen()
