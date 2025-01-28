extends Node3D

@onready var weapon: MeshInstance3D = $Weapon
@onready var anim_player: AnimationPlayer = $AnimationPlayer

signal reload

func play_gun_anim(anim_name : String, speed_scale : float = 1):
	anim_player.stop() # Stop any current animation
	
	anim_player.speed_scale = speed_scale # Set speed
	anim_player.play(anim_name) # Play set anim

func reload_finished():
	reload.emit()
