extends Node

var collected_powerups = []

# Combo system: define combo triggers
var combo_active = false
var combo_timer = 0.0
var combo_duration = 5.0  # Time limit for combo to be triggered

const power_ups = preload("res://powerup/power_ups.gd")

func _ready():
	for power_up in get_tree().get_nodes_in_group("power_ups"):
		power_up.connect("collected", Callable(self, "_on_power_up_collected"))

func _process(delta: float) -> void:
	if combo_active:
		combo_timer -= delta  # Countdown for the combo effect
		
	if combo_timer <= 0:
		print("Combo expired!")
		_reset_combo()
		
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
			
		power_ups.PowerUpType.PILLS:
			_apply_pills_effect()
	# Check for combo
	
	_check_for_comboA()

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

func _apply_pills_effect():
	print("Player gets pills!")
	# Add your effect logic, e.g., unlocking a car or a speed boost
	
func _check_for_comboA():
	if power_ups.PowerUpType.SMOKING in collected_powerups and power_ups.PowerUpType.DRINKING in collected_powerups:
		_activate_combo()
	elif power_ups.PowerUpType.SNUSING in collected_powerups and power_ups.PowerUpType.DRINKING in collected_powerups:
		_activate_combo()
	elif power_ups.PowerUpType.PILLS in collected_powerups and power_ups.PowerUpType.DRINKING in collected_powerups:
		_activate_combo()

func _activate_combo():
	if !combo_active:
		combo_active = true
		combo_timer = combo_duration  # Reset combo timer
		print("Combo activated!")
# Reset combo state after timer runs out
func _reset_combo():
	combo_active = false
	print("Combo expired.")
	 # Reset combo effects here, if needed_
