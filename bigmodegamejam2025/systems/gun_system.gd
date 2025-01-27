extends Node

@export var parent : CharacterBody3D
@onready var cooldown_timer: Timer = $CooldownTimer

var current_gun : Gun

func shoot():
	current_gun = parent.current_gun
	
	if parent.can_shoot == true and parent.current_bullets > 0:
		var valid_bullets : Array[Dictionary] = get_bullet_raycasts()
		
		if current_gun.type != Gun.GunType.MELEE: # Subtract bullets if weapon uses bullets
			parent.current_bullets -= 1
		
		# Cooldown
		parent.can_shoot = false
		cooldown_timer.start(current_gun.cooldown)
		
		# Sound Effect
		# GLOBALCLASS ---- SoundManager.play_sfx(current.gun.firing_sounds.pick_random(), parent)
		

func get_bullet_raycasts():
	pass
