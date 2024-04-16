extends Control

#TODO: remember between runs of game

func _ready():
	$"master volume slider".value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$"sfx volume slider".value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$"music volume slider".value = db_to_linear(AudioServer.get_bus_volume_db(2))
	$"vsync checkbox".set_pressed_no_signal(DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED)


func _on_master_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_sfx_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func _on_music_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))


func _on_toggle_fullscreen_button_pressed():
	Global.toggle_fullscreen()


func _on_vsync_checkbox_toggled(toggled_on):
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
