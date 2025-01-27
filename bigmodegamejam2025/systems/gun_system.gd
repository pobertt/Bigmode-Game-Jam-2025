extends Node

@export var parent : CharacterBody3D
@onready var cooldown_timer: Timer = $CooldownTimer

var current_gun : Gun

func shoot():
	current_gun = parent.current_gun
	
	if parent.can_shoot == true and parent.current_bullets > 0:
		var valid_bullets : Array[Dictionary] = get_bullet_raycasts()
		
func get_bullet_raycasts():
	pass
