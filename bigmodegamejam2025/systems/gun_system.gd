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
		
		# if any bullets hits do all this stuff
		if valid_bullets.is_empty() == false:
			for b in valid_bullets:
				# Enemy Damage
				if b.hit_target.is_in_group("enemy"): # Check if is enemy
					b.hit_target.change_health(current_gun.damage * -1) # Can change this later but hurt/damage/kill enemy
				
				# Spawn Decal
				var bullet = Global.BULLET_DECAL.instantiate()
				b.hit_target.add_child(bullet)
				bullet.global_transform.origin = b.collision_point
				
				# Match decal direction to surface normal
				if b.collision_normal  == Vector3(0,1,0):
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.RIGHT)
				elif b.collision_normal == Vector3(0,-1,0):
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.RIGHT)
				else:
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.DOWN)
				
				# Add to decal counting array
				Global.spawned_decals.append(bullet)
				
				# Check for decal amount
				if Global.spawned_decals.size() > Global.max_decals:
					Global.spawned_decals[0].queue_free() # Remove oldest decal from the world
					Global.spawned_decals.remove_at(0) # Remove freed decal from list

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

func _on_cooldown_timer_timeout() -> void:
	parent.can_shoot = true
