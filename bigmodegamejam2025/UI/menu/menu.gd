extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://map/world.tscn")
	Global.update_hud.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()
