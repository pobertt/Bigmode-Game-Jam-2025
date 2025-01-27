extends CharacterBody3D

@onready var camera: Camera3D = $head/camera
var collected_powerups = []

# Combo system: define combo triggers
var combo_active = false
var combo_timer = 0.0
var combo_duration = 5.0  # Time limit for combo to be triggered

const power_ups = preload("res://player/power_ups.gd")


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _ready():
	# Capturing the mouse to the screen.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# CONNECTS TO POWER UP SIGNALS IN POWER UPS SCRIPT
	for power_up in get_tree().get_nodes_in_group("power_ups"):
		power_up.connect("collected", Callable(self, "_on_power_up_collected"))
	
	

# FOR WHEN THE PLAYER COLLECTS A POWER UP
func _on_power_up_collected(power_up_type):
	if power_up_type not in collected_powerups:
		collected_powerups.append(power_up_type)
	match power_up_type:
		power_ups.PowerUpType.SMOKING:
			_apply_smoking_effect()
			
		power_ups.PowerUpType.DRINKING:
			_apply_drinking_effect()
			
		power_ups.PowerUpType.SNUSING:
			_apply_snusing_effect()
			
		power_ups.PowerUpType.CAR_KEYS:
			_apply_car_keys_effect()
	# Check for combo
	_check_for_combo1()
	_check_for_combo2()
	_check_for_combo3()

# Apply individual effects for each power-up
func _apply_smoking_effect():
	print("Player starts smoking!")
	# Add your effect logic, e.g., reduce health or stamina

func _apply_drinking_effect():
	print("Player starts drinking!")
	# Add your effect logic, e.g., blur vision, or increase energy

func _apply_snusing_effect():
	print("Player uses snus!")
	# Add your effect logic, e.g., alertness or focus

func _apply_car_keys_effect():
	print("Player gets car keys!")
	# Add your effect logic, e.g., unlocking a car or a speed boost
	
func _check_for_combo1():
	if power_ups.PowerUpType.SMOKING in collected_powerups and power_ups.PowerUpType.DRINKING in collected_powerups:
		combo_active = true
		combo_timer = combo_duration  # Reset combo timer
		print("Combo activated!")
		# Apply combo effect, like boosting speed or unlocking a special ability
		
		
	if combo_active:
		combo_timer -= get_process_delta_time()  # Decrease timer
		if combo_timer <= 0:
			# Reset combo after timer expires
			_reset_combo()
			
		
func _check_for_combo2():
	if power_ups.PowerUpType.SNUSING in collected_powerups and power_ups.PowerUpType.DRINKING in collected_powerups:
		combo_active = true
		combo_timer = combo_duration  # Reset combo timer
		print("Combo activated!")
		# Apply combo effect, like boosting speed or unlocking a special ability
		
		
	if combo_active:
		combo_timer -= get_process_delta_time()  # Decrease timer
		if combo_timer <= 0:
			# Reset combo after timer expires
			_reset_combo()
			
func _check_for_combo3():
	if power_ups.PowerUpType.CAR_KEYS in collected_powerups and power_ups.PowerUpType.DRINKING in collected_powerups:
		combo_active = true
		combo_timer = combo_duration  # Reset combo timer
		print("Combo activated!")
		# Apply combo effect, like boosting speed or unlocking a special ability
		
		
	if combo_active:
		combo_timer -= get_process_delta_time()  # Decrease timer
		if combo_timer <= 0:
			# Reset combo after timer expires
			_reset_combo()
			
# Reset combo state after timer runs out
func _reset_combo():
	combo_active = false
	print("Combo expired.")
	 # Reset combo effects here, if needed

func _unhandled_input(event: InputEvent) -> void:
	# Camera Rotation.
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if combo_active:
		combo_timer -= delta  # Countdown for the combo effect

func _physics_process(delta: float) -> void:
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
	
	
