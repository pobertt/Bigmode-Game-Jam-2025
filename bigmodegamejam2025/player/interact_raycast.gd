extends RayCast3D

@export var parent : CharacterBody3D

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
					obj.keg_particle.emitting = true
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
