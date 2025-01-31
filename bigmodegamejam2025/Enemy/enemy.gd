extends CharacterBody3D

@onready var navref = $NavigationAgent3D
@onready var VisionRef = $VisionArea
@onready var RayCast = $VisionRayCast
@onready var AggroTimer = $AggroTimer
@onready var IdleTimer = $IdleTimer
@onready var DamageAreaRef = $DamageArea
@onready var animation_player: AnimationPlayer = $policeresizedanims/AnimationPlayer
@onready var skeleton = $policeresizedanims/Armature/Skeleton3D
var PlayerRef


enum STATE { ROAMING , CHASING , IDLING , SEARCHING, DYING}

var CurrentState : STATE = STATE.IDLING

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
	navref.target_desired_distance = 2.0
	navref.path_desired_distance = 2.0
	
#every time the timer elapses
func _on_vision_timer_timeout():
	if CurrentState != STATE.DYING:
		
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
				CurrentState = STATE.SEARCHING
			else:
				pass
			print("StillFollowing")		
	
		var damageoverlaps = DamageAreaRef.get_overlapping_bodies()
	
		if damageoverlaps.size() > 0:
			for overlap in damageoverlaps:
				if overlap.name == "Player":
					#playerdamage function goes here
					print("DamagePlayer")
					#apply_central_impulse(overlap.basis.z * 2.0)
	else:
		print("dead")
			


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
			CurrentState = STATE.CHASING    
			animation_player.play("run")                                                     
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
				CurrentState = STATE.SEARCHING
			RayCast.debug_shape_custom_color = Color.GREEN

func _GoTowardsPlayer():
	var playerposition = PlayerRef.global_transform.origin
	#we commence look at, but adjust it so the y-axis of the player is in line with the enemy
	look_at(Vector3(playerposition.x, global_position.y, playerposition.z), Vector3.UP, true)
	target_position(playerposition)
	

func _on_aggro_timer_timeout() -> void:
	PlayerRef = null
	print("StopFollowing")


func _on_navigation_agent_3d_target_reached() -> void:
	match CurrentState:
		STATE.ROAMING:
			CurrentState = STATE.IDLING
			IdleTimer.start()
			animation_player.play("looking around")
		STATE.CHASING:
			pass
		STATE.SEARCHING:
			CurrentState = STATE.IDLING
			IdleTimer.start()
			animation_player.play("idle 2")

func change_health(damage):
	print("Hit enemy")
	var bones = skeleton.get_children()
	look_at(Vector3(Global.player_ref.global_position.x, global_position.y, Global.player_ref.global_position.z), Vector3.UP, true)
	#animation_player.pause()
	for bone in bones:
		if bone.get_child_count() > 0:
			for bonecollision in bone.get_children():
				if bonecollision.get_class() == "CollisionShape3D":
					bonecollision.disabled = false
	skeleton.physical_bones_start_simulation()
	for bone in bones:
		if bone.get_class() == "PhysicalBone3D":
			bone.apply_central_impulse(-Global.player_ref.basis.z * 100.0)
			#global_transform.basis.z.normalized() * Vector3(1, 10, -100)
	velocity = Vector3(0, 0, 0)
	navref.velocity = Vector3(0, 0, 0)
	target_position(self.global_position)
	CurrentState = STATE.DYING
	if CurrentState == STATE.DYING:
		#$CollisionShape3D.queue_free()
		pass
	
	
	
func _on_idle_timer_timeout() -> void:
	var randompos = Vector3(randf_range(-20, 20), position.y,randf_range(-20, 20))
	look_at(Vector3(randompos.x, global_position.y, randompos.z), Vector3.UP, true)
	target_position(randompos)
	print(randompos)
	CurrentState = STATE.ROAMING
	animation_player.play("walking")
	
