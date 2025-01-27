extends CharacterBody3D


@onready var navref = $NavigationAgent3D
@onready var VisionRef = $VisionArea
@onready var RayCast = $VisionRayCast

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y -= 2

	var next_location = navref.get_next_path_position()
	var current_location = global_transform.origin
	#normalise for consistent speed
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	velocity = new_velocity
	
	#smoothly adjust velocity
	#velocity = velocity.move_toward(new_velocity, 0.25)
	
	#apply motion
	move_and_slide()

func target_position(target):
	navref.target_position = target
	
func update_taarget_location(target_location):
	navref.set_target_location(target_location)



#every time the timer elapses
func _on_vision_timer_timeout():
	#check overlapping bodies
	var overlaps = VisionRef.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			#confirm its the player
			if overlap.name == "Player":
				#update raycast with player location
				var playerposition = overlap.global_transform.origin
				RayCast.look_at(playerposition, Vector3.UP)
				RayCast.force_raycast_update()
				
				#if raycast is colliding
				if RayCast.is_colliding():
					#get collider
					var collider = RayCast.get_collider()
					#if colliding with player
					if collider.name == "Player":
						RayCast.debug_shape_custom_color = Color.RED
						print("I see you")
					#if not colliding with player
					else:
						RayCast.debug_shape_custom_color = Color.GREEN
						print("I don't see you")
