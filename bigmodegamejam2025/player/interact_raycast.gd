extends RayCast3D

@export var parent : CharacterBody3D

const DRINKING_SOUNDS = [
	preload("res://SFX/PowerUps/DRINKING.mp3"),
	preload("res://SFX/player/Beer.wav")
]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_colliding():
		Global.can_interact = true
		Global.update_interact.emit()
		if Input.is_action_just_pressed("interact"):
			if get_collider().is_in_group("enemy"):
				print("interact enemy")
			if get_collider().is_in_group("object"):
				var obj = get_obj()
				if obj.obj_type == 3:
					var random_drinking_sound = DRINKING_SOUNDS[randi() % DRINKING_SOUNDS.size()]
	
					var drinking_player = AudioStreamPlayer3D.new()
					drinking_player.stream = random_drinking_sound
					drinking_player.global_position = parent.global_position
					parent.add_child(drinking_player)
					drinking_player.play()
					
		if Input.is_action_pressed("interact"):
			if get_collider().is_in_group("enemy"):
				print("HELD interact enemy")
			if get_collider().is_in_group("object"):
				var obj = get_obj()
				if obj.obj_type == 3 and parent.bladder <= 1000:
					obj.keg_particle.emitting = true
					parent.strength += 1
					parent.bladder += 1
					
					Global.update_piss_bar.emit(1, true)
		elif Input.is_action_just_released("interact") and get_collider().is_in_group("object"):
			var obj = get_obj()
			if obj.obj_type == 3:
				obj.keg_particle.emitting = false

	else:
		Global.can_interact = false
		Global.update_interact.emit()

func get_obj():
	var obj = parent.interact_raycast.get_collider()
	print(obj.obj_type)
	return obj
