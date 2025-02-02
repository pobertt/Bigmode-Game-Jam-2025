extends CharacterBody3D

# Player Nodes

@onready var camera : Camera3D = $Head/Camera
@onready var p_particle: Node3D = $Head/Camera/PParticle
@onready var screen_distort: ColorRect = $Head/Camera/Control/ScreenDistort
@onready var obj_holder: Node3D = $Head/Camera/obj_holder
@export var achievement_manager: Node

var DAMAGE_SOUNDS = [
	preload("res://SFX/player/Hurt1.wav"),
	preload("res://SFX/player/Hurt2.wav"),
	preload("res://SFX/player/I_dont_like_that.wav"),
]
# System Nodes

@onready var gun: Node = $GunSystem

# Raycast

@onready var bullet_raycast : RayCast3D = $Head/Camera/Bullet_RayCast3D
@onready var weapon_holder: Node3D = $Head/Camera/WeaponHolder
@onready var interact_raycast: RayCast3D = $Head/Camera/InteractRaycast

# Stats

var health : int = 100
var bladder : int = 0
var strength : float = 10
var snusM : int = 1
var piss : bool = false

# Guns

@export var current_gun : Gun = PISTOL
var can_shoot : bool = true
var is_reloading : bool = false
var current_bullets : int = current_gun.max_mag

const MELEE = preload("res://resources/guns/melee.tres")
const PISTOL = preload("res://resources/guns/pistol.tres")
const SHOTGUN = preload("res://resources/guns/shotgun.tres")

var ammo : Dictionary = {
	"melee" : 1,
	"pistol" : 200,
	"shotgun" : 200,
	"smg" : 200,
}

# Movement Var

var speed = WALK_SPEED
const WALK_SPEED = 12
const JUMP_VELOCITY = 4.5

# CAM VARS

const BOB_FREQ : float = 2.0
const BOB_AMP : float = 0.1
var t_bob : float = 0.0

func _ready():
	Global.player_ref = self
	
	gun.player_ready()
	
	# Capturing the mouse to the screen.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	Global.update_hud.emit()
	
	
func _unhandled_input(event: InputEvent) -> void:
	# Camera Rotation.
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	# Reload
	if event.is_action_pressed("reload") and Global.check_menus() == false:
		gun.reload()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		Global.pause_ref.pause_menu()
		
	# Swap Guns
	if event.is_action_pressed("gun_slot_1") and is_reloading == false and Global.check_menus() == false:
		switch_weapon(PISTOL)
	if event.is_action_pressed("gun_slot_2") and is_reloading == false and Global.check_menus() == false:
		switch_weapon(SHOTGUN)
	if event.is_action_pressed("piss") and Global.check_menus() == false:
		if bladder > 0:
			achievement_manager.unlock_achievement("The world is my toilet")
			piss = true
			
			p_particle.piss()
	if event.is_action_released("piss") and Global.check_menus() == false:
		piss = false
		p_particle.piss()

func _process(delta: float) -> void:
	if piss == true:
		bladder -= 0.0001*delta
		screen_distort.material.set_shader_parameter("shader_parameter/speed", 0.5) 

		Global.decrease_piss_bar.emit(bladder)
	if bladder == 0:
		piss = false
		p_particle.piss()
	if bladder == 1000:
		achievement_manager.unlock_achievement("When you have to go, you have to go")

func _physics_process(delta: float) -> void:
	# Gun
	# Semi-Automatic
	if Input.is_action_just_pressed("attack") and current_gun.automatic == false and Global.check_menus() == false and current_gun != MELEE:
		gun.shoot()
	# Automatic
	if Input.is_action_pressed("attack") and current_gun.automatic == true and Global.check_menus() == false and current_gun != MELEE:
		gun.shoot()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and Global.check_menus() == false:
		velocity.y = JUMP_VELOCITY

	if is_on_floor():
		if get_direction():
			velocity.x = get_direction().x * speed * snusM
			velocity.z = get_direction().z * speed * snusM
		else:
			velocity.x = lerp(velocity.x, get_direction().x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, get_direction().x * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, get_direction().x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, get_direction().z * speed, delta * 3.0)
	
	# Headbob stuff:
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV stuff:
	
	move_and_slide()

func get_direction() -> Vector3:
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	return direction

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func switch_weapon(new_weapon : Gun):
	if new_weapon == current_gun: # Do nothing if already using that gun
		return
	
	# Add bullets back to total ammo count
	ammo[current_gun.ammo] += current_bullets
	current_bullets = 0
	
	#Switch Gun Resource
	current_gun = new_weapon
	
	# Set in-game mesh
	weapon_holder.update_mesh(current_gun.mesh)
	weapon_holder.set_particle(current_gun.type)
	
	# Load bullets into new gun
	match ammo[current_gun.ammo] >= current_gun.max_mag: # Check if the player has enough ammo to fill the mag
		true: # Fill Mag
			current_bullets = current_gun.max_mag
			ammo[current_gun.ammo] -= current_gun.max_mag
		false: # Partially Fill Mag
			current_bullets += ammo[current_gun.ammo]
			ammo[current_gun.ammo] = 0
	
	Global.update_hud.emit()


func _camera_shake(period, magnitude):
	var initial_transform = camera.transform 
	var elapsed_time = 0.0

	while elapsed_time < period:
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0.0
		)

		camera.transform.origin = initial_transform.origin + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

	camera.transform = initial_transform

func change_health(damage):
	health -= damage
	Global.update_hud.emit()
	
	var random_damage_sounds = DAMAGE_SOUNDS[randi() % DAMAGE_SOUNDS.size()]
	
	var damage_player = AudioStreamPlayer3D.new()
	damage_player.stream = random_damage_sounds
	damage_player.global_position = global_position
	add_child(damage_player)
	damage_player.play()
	
	if health <= 0:
		print("dead")
