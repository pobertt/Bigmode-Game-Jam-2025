extends CharacterBody3D


@onready var navref = $NavigationAgent3D
@onready var VisionRef = $VisionArea
@onready var RayCast = $VisionRayCast
@onready var AggroTimer = $AggroTimer

var PlayerRef

const SPEED = 2.0
const JUMP_VELOCITY = 4.5

	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y -= 2
	
	#check next target position
	var next_location = navref.get_next_path_position()
	#get current position
	var current_location = global_transform.origin
	#normalise for consistent speed
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	#set velocity
	velocity = new_velocity
	
	#smoothly adjust velocity
	velocity = velocity.move_toward(new_velocity, 0.25)
	
	#apply motion
	move_and_slide()

#set next target position
func target_position(target):
	navref.target_position = target
	
#every time the timer elapses
func _on_vision_timer_timeout():
	#check overlapping bodies
	var overlaps = VisionRef.get_overlapping_bodies()
	var foundplayer = false
	if overlaps.size() > 0:
		for overlap in overlaps:
			#confirm its the player
			if overlap.name == "Player":
				#set playerref for following after lostsight
				PlayerRef = overlap
				foundplayer = true
				#update raycast with player location
				_TrackPlayerRaycast()
	#if player wasn't found but still exists in memory
	if PlayerRef != null and foundplayer == false:
		#if no aggro yet, start timer and save last position
		if AggroTimer.time_left == 0.0:
			AggroTimer.start()
			_GoTowardsPlayer()
		else:
			pass
		print("StillFollowing")
	

#manage enemy line of sight
func _TrackPlayerRaycast():
	RayCast.look_at(PlayerRef.global_transform.origin, Vector3.UP)
	RayCast.force_raycast_update()
	#check what the raycast is colliding with
	if RayCast.is_colliding():
		#get collider
		var collider = RayCast.get_collider()
		#if raycast can see player e.g. not hidden
		if collider.name == "Player":
			RayCast.debug_shape_custom_color = Color.RED
			print("I see you")
			#if aggro was kept but seen again
			if AggroTimer.time_left != 0.0:
				AggroTimer.stop()
			_GoTowardsPlayer()
		#if not colliding with player but still searching
		elif collider.name != "Player" and PlayerRef != null:
			if AggroTimer.time_left != 0.0:
				pass
			else:
				#if no aggro yet, start timer and save last position
				print("I lost you")
				#start/restart timer for aggro
				AggroTimer.start()
				_GoTowardsPlayer()
			RayCast.debug_shape_custom_color = Color.GREEN

func _GoTowardsPlayer():
	var playerposition = PlayerRef.global_transform.origin
	#we commence look at, but adjust it so the y-axis of the player is in line with the enemy
	look_at(Vector3(playerposition.x, global_position.y, playerposition.z), Vector3.UP, true)
	target_position(playerposition)
	

func _on_aggro_timer_timeout() -> void:
	PlayerRef = null
	print("StopFollowing")
