extends RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_colliding():
		Global.can_interact = true
		Global.update_interact.emit()
		if Input.is_action_just_pressed("interact"):
			if get_collider().is_in_group("enemy"):
				print("interact")
	else:
		Global.can_interact = false
		Global.update_interact.emit()
