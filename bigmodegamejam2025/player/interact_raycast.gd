extends RayCast3D

@export var parent : CharacterBody3D

const DRINKING_SOUNDS = [
	preload("res://SFX/PowerUps/DRINKING.mp3"),
	preload("res://SFX/player/Beer.wav")
]

const PILL_SOUNDS = [
	preload("res://SFX/PowerUps/SWALLOW.mp3"),
	preload("res://SFX/player/Pills.wav")
] 

var food = preload("res://objects/food.tscn")
var new_food = food.instantiate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_colliding():
		Global.can_interact = true
		Global.update_interact.emit()
		
		if Input.is_action_pressed("interact"):
			if get_collider() && get_collider().is_in_group("enemy"):
				print("HELD interact enemy")
			if get_collider() && get_collider().is_in_group("object") :
				var obj = get_obj()
				if obj.obj_type == 3 and parent.bladder <= 1000:
					obj.keg_particle.emitting = true
					parent.strength += 1
					parent.bladder += 1
					Global.update_piss_bar.emit(1, true)
				elif obj.obj_type == 4:
					print("vending")
				elif obj.obj_type == 5:
					print("food")
					
	
		elif Input.is_action_just_released("interact") and get_collider() and get_collider().is_in_group("object"):
			var obj = get_obj()
			if obj.obj_type == 3:
				obj.keg_particle.emitting = false
		
		if Input.is_action_just_pressed("interact"):
			if get_collider() and get_collider().is_in_group("enemy"):
				var enemy = get_collider()
				enemy.hit_sounds()
			if get_collider() and get_collider().is_in_group("object"):
				var obj = get_obj()
				if obj.obj_type == 3:
					var random_drinking_sound = DRINKING_SOUNDS[randi() % DRINKING_SOUNDS.size()]
					var drinking_player = AudioStreamPlayer3D.new()
					drinking_player.stream = random_drinking_sound
					drinking_player.global_position = parent.global_position
					parent.add_child(drinking_player)
					drinking_player.play()
				elif obj.obj_type == 4:
					var new_food = food.instantiate()
					new_food.global_position = Vector3(parent.global_position.x, parent.global_position.y + 2, parent.global_position.z + 1)
					get_tree().get_root().add_child(new_food)
				elif obj.obj_type == 5:
					obj.eaten()
					parent.health += 10
					
					Global.update_hud.emit()
					
					var random_pill_sound = PILL_SOUNDS[randi() % PILL_SOUNDS.size()]
					
					var pill_player = AudioStreamPlayer3D.new()
					pill_player.stream = random_pill_sound
					pill_player.global_position = parent.global_position
					parent.add_child(pill_player)
					pill_player.play()
	
	else:
		Global.can_interact = false
		Global.update_interact.emit()

func get_obj():
	var obj = parent.interact_raycast.get_collider()
	print(obj.obj_type)
	return obj
