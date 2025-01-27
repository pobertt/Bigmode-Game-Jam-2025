extends CharacterBody3D

@onready var navref = $NavigationAgent3D

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
	
	#smoothly adjust velocity
	velocity = velocity.move_toward(new_velocity, 0.25)
	
	#apply motion
	move_and_slide()


func target_position(target):
	navref.target_position = target
