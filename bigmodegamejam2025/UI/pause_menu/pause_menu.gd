extends Control

@onready var game_label: Label = $CenterContainer/Panel/MarginContainer/Button_Container/GameLabel
@onready var quit_button: Button = $CenterContainer/Panel/MarginContainer/Button_Container/Quit_Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_open : bool = false

func _ready() -> void:
	Global.pause_ref = self

## Open / Close
func pause_menu():
	match is_open:
		true:
			get_tree().paused = false
			close()
		false:
			get_tree().paused = true
			open()

func open():
	#Show Pause Menu
	show()
	animation_player.play("pause")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	is_open = true

func close():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("unpause")
	is_open = false


## Buttons
func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_resume_button_pressed() -> void:
	close()
	get_tree().paused = false
