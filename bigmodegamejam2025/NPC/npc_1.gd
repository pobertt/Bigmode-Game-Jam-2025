extends CharacterBody3D

@onready var navref = $NavigationAgent3D
@onready var VisionRef = $VisionArea
@onready var RayCast = $VisionRayCast
@onready var AggroTimer = $AggroTimer
@onready var IdleTimer = $IdleTimer
@onready var vision_timer: Timer = $VisionTimer
@onready var deathtimer: Timer = $deathtimer
@onready var DamageAreaRef = $DamageArea
@onready var animation_player: AnimationPlayer = $animsfornpc/AnimationPlayer
@onready var skeleton = $animsfornpc/Armature/Skeleton3D
@onready var enemy_capsule: CollisionShape3D = $CollisionShape3D
@onready var vision_cone_collision: CollisionShape3D = $VisionArea/VisionConeCollision
@onready var particles_collision: GPUParticlesCollisionSphere3D = $GPUParticlesCollisionSphere3D
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


@export var audio_hit : AudioStream
@export var audio_death : AudioStream

var PlayerRef
var health = 100


enum STATE { ROAMING , CHASING , IDLING , SEARCHING, DYING}

var CurrentState : STATE = STATE.IDLING

const SPEED = 2.0
const JUMP_VELOCITY = 4.5
	
func _ready() -> void:
	skeleton.animate_physical_bones = true
	_on_idle_timer_timeout()
	

func _physics_process(delta: float) -> void:
	if CurrentState != STATE.DYING:
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
	#check overlapping bodies on vision
	var overlaps = VisionRef.get_overlapping_bodies()
	var foundplayer = false
	
	if overlaps.size() > 0:
		for overlap in overlaps:
			#confirm its the player
			if overlap.name == "Player" and health != 100:
				#set playerref for following after lostsight
				PlayerRef = overlap
				#update raycast with player location
				foundplayer = _TrackPlayerRaycast()

	#if player wasn't found but still searching
	if CurrentState == STATE.CHASING and foundplayer == false:
		#if no aggro yet, start timer and save last position
		if AggroTimer.time_left == 0.0:
			AggroTimer.start()
			_GoTowardsPlayer()
			CurrentState = STATE.SEARCHING
		else:
			pass	
	
	if CurrentState == STATE.CHASING:
		#check damage overlap
		var damageoverlaps = DamageAreaRef.get_overlapping_bodies()
		if damageoverlaps.size() > 0:
			for overlap in damageoverlaps:
				#check its player
				if overlap.name == "Player":
					#playerdamage function goes here
					print("DamagePlayer")
					#apply_central_impulse(overlap.basis.z * 2.0)
				else:
					pass
			


#manage enemy line of sight
func _TrackPlayerRaycast():
	#raycast locks to them
	RayCast.look_at(PlayerRef.global_transform.origin, Vector3.UP)
	#raycast
	RayCast.force_raycast_update()
	#check what the raycast is colliding with
	if RayCast.is_colliding():
		#get collider
		var collider = RayCast.get_collider()
		#if raycast can see player e.g. not hidden
		if collider.name == "Player":
			RayCast.debug_shape_custom_color = Color.RED
			print("I see you")
			#stop timers if active
			IdleTimer.stop()
			AggroTimer.stop()
			_GoTowardsPlayer()
			CurrentState = STATE.CHASING    
			if health <= 50:
				animation_player.play("injuredrun")  
			else:
				animation_player.play("narutorun") 
			return	true                                                   
		#if not colliding with player but still chasing
		elif collider.name != "Player" and CurrentState == STATE.CHASING:
			#start timer if not started already
			if AggroTimer.time_left == 0.0:
				#if no aggro yet, start timer and save last position
				print("I lost you")
				#start/restart timer for aggro
				AggroTimer.start()
				_GoTowardsPlayer()
				CurrentState = STATE.SEARCHING
				RayCast.debug_shape_custom_color = Color.GREEN
			return false
		else:
			#else set debug cast colour
			RayCast.debug_shape_custom_color = Color.GREEN
			return false

#Head to players last know location and look at
func _GoTowardsPlayer():
	var playerposition = PlayerRef.global_transform.origin
	#we commence look at, but adjust it so the y-axis of the player is in line with the enemy
	look_at(Vector3(playerposition.x, global_position.y, playerposition.z), Vector3.UP, true)
	target_position(playerposition)
	
#when aggro lost, reset player ref
func _on_aggro_timer_timeout() -> void:
	CurrentState = STATE.IDLING
	animation_player.play("idle 2")
	IdleTimer.start()
	print("StopFollowing")

#when reached, change based on state
func _on_navigation_agent_3d_target_reached() -> void:
	match CurrentState:
		STATE.ROAMING:
			#when roaming, walk around
			CurrentState = STATE.IDLING
			IdleTimer.start()
			var animarray = ["breakdance", "idle", "salsa", "twerk"]
			animation_player.play(animarray[randi_range(0, animarray.size() - 1)])
		STATE.SEARCHING:
			#when searching, head to last location and start roaming cycle again
			CurrentState = STATE.IDLING
			IdleTimer.start()
			animation_player.play("sillydance")

#function to launch ragdoll on hit
func launchragdoll():
	for child in Global.player_ref.get_children():
		if child.name == "GunSystem":
			var raycast = child.get_bullet_raycasts()
			var hitbones = false
			#if raycast hits bone
			for cast in raycast:
				if cast["hit_target"].get_class() == "PhysicalBone3D":
					print(cast["hit_target"])
					print(cast["hit_target"].global_position)
					cast["hit_target"].apply_impulse(-Global.player_ref.basis.z * 50.0, cast["hit_target"].global_position)
					hitbones = true
			#if no bone impulse, add random
			if hitbones == false:
				randomlaunch()
				return
	
#pick a random bone and add impulse (executes when no bone is hit)
func randomlaunch():
	var launch = false
	while launch == false:
		var bones = skeleton.get_children()
		var randombone = skeleton.get_child(randi_range(0, bones.size()))
		if randombone.get_class() == "PhysicalBone3D":
			randombone.apply_impulse(-Global.player_ref.basis.z * 50.0, randombone.global_position)
			print("random impulse on" + str(randombone.name))
			launch = true


func change_health(damage):
	#clamp healh
	health = clamp(health - damage, 0, 100)
	
	#if dead
	if health <= 0:
		#set next position for nav to self
		target_position(global_position)
		#disable other collisions
		enemy_capsule.disabled = true
		vision_cone_collision.disabled = true
		$DamageArea/CollisionShape3D.disabled = true
		#get bones
		var bones = skeleton.get_children()
		#stop animations
		animation_player.active = false
		#activate bones so they can move
		for bone in bones:
			if bone.get_child_count() > 0:
				for bonecollision in bone.get_children():
					if bonecollision.get_class() == "CollisionShape3D":
						bonecollision.disabled = false
	
		#start sim
		skeleton.physical_bones_start_simulation()

		#launch ragdoll
		launchragdoll()

		#stops movement
		CurrentState = STATE.DYING
		#stop timers
		if AggroTimer.time_left != 0:
			AggroTimer.stop()
		if IdleTimer.time_left != 0:
			IdleTimer.stop()
		if vision_timer.time_left != 0:
			vision_timer.stop()
			#start timer to destroy node
		deathtimer.start()
		audio_stream_player.stream = audio_death
		audio_stream_player.play()
		return
	else:
		audio_stream_player.stream = audio_hit
		audio_stream_player.play()
	
#on idle timer end
func _on_idle_timer_timeout() -> void:
	#wander
	var randompos = Vector3(randf_range(-20, 20), position.y,randf_range(-20, 20))
	look_at(Vector3(randompos.x, global_position.y, randompos.z), Vector3.UP, true)
	target_position(randompos)
	CurrentState = STATE.ROAMING
	animation_player.play("walk")
	

#once timer finishes, destroy node
func _on_deathtimer_timeout() -> void:
	skeleton.physical_bones_stop_simulation()
	queue_free()
