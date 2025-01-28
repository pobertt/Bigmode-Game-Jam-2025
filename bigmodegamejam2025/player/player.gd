extends CharacterBody3D

# Player Nodes
@onready var camera : Camera3D = $Head/Camera

# System Nodes
@onready var gun: Node = $GunSystem

# Raycast
@onready var bullet_raycast : RayCast3D = $Head/Camera/Bullet_RayCast3D

# Stats

# Guns
var current_gun : Gun = SHOTGUN
var can_shoot : bool = true
var is_reloading : bool = false
var current_bullets : int = current_gun.max_mag

const MELEE = preload("res://resources/guns/melee.tres")
const SHOTGUN = preload("res://resources/guns/shotgun.tres")

var ammo : Dictionary = {
	"melee" : 1,
	"pistol" : 200,
	"shotgun" : 200,
	"smg" : 200,
}

# Movement Var
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	# Capturing the mouse to the screen.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	# Camera Rotation.
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# Gun
	# Semi-Automatic
	if Input.is_action_just_pressed("attack") and current_gun.automatic == false and Global.check_menus() == false:
		gun.shoot()
	# Automatic
	if Input.is_action_pressed("attack") and current_gun.automatic == true and Global.check_menus() == false:
		gun.shoot()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
