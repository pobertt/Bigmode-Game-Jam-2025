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
	current_gun = parent.current_gun
	
	var bullet_raycast = parent.bullet_raycast
	var valid_bullets : Array[Dictionary]
	
	for b in current_gun.bullet_amt:
		# Get Spread Amount
		var spread_x : float = randf_range(current_gun.spread * -1, current_gun.spread)
		var spread_y : float = randf_range(current_gun.spread * -1, current_gun.spread)
		
		# Set Spread
		bullet_raycast.target_position  = Vector3(spread_x, spread_y, -current_gun.bullet_range)
		
		# Get Collided Data
		bullet_raycast.force_raycast_update()
		var hit_target = bullet_raycast.get_collider()
		var collision_point = bullet_raycast.get_collision_point()
		var collision_normal = bullet_raycast.get_collision_normal()
		
		# If the bullet hit an object, get it's data
		if hit_target != null:
			var valid_bullet : Dictionary = {
				"hit_target" : hit_target,
				"collision_point" : collision_point,
				"collision_normal" : collision_normal,
			}
			
			# Add valid bullet data to array (getting each individual bullet cause shotgun init)
			valid_bullets.append(valid_bullet)
			
		# Send valid bullet data
		return valid_bullets
