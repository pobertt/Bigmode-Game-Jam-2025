extends Node
class_name PowerUpSystem

@export var player_ref : CharacterBody3D
const SMOKE_SOUND = preload("res://SFX/PowerUps/LIGHTING.mp3")
const DRINKING_SOUND = preload("res://SFX/PowerUps/DRINKING.mp3")
const PILL_SOUND = preload("res://SFX/PowerUps/SWALLOW.mp3")
const SNUS_SOUND = preload("res://SFX/PowerUps/SWALLOW.mp3")

var collected_powerups = []

# Combo system: define combo triggers
var combo_active = false
var combo_timer = 0.0
var combo_duration = 5.0  # combo length 
var clear_timer = 0.0  # Timer for clearing collected power-ups
var clear_duration = 5.0  # power-up length
var collected_p = false
var original_fov : float

const power_ups = preload("res://powerup/power_ups.gd")

func _ready():
	for power_up in get_tree().get_nodes_in_group("power_ups"):
		power_up.connect("collected", Callable(self, "_on_power_up_collected"))

func _process(delta: float) -> void:
	if combo_active:
		combo_timer -= delta  # Countdown for the combo effect
		
	if combo_timer <= 0:
		_reset_combo()
		
	if player_ref.bladder >= 600:
		player_ref.screen_distort.visible=true
	else:
		player_ref.screen_distort.visible=false
		
	if collected_p:
		if !combo_active:
			clear_timer += delta  # Handle the clear timer for power-ups
			if clear_timer >= clear_duration:
				clear_collected_powerups()
		
# FOR WHEN THE PLAYER COLLECTS A POWER UP
func _on_power_up_collected(power_up_type):
	if power_up_type not in collected_powerups:
		collected_powerups.append(power_up_type)
		collected_p = true
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
	player_ref.health += 10
	print(player_ref.health)
	
	Global.lighting.emit()
	
	var smoke_player = AudioStreamPlayer3D.new()
	smoke_player.stream = SMOKE_SOUND
	smoke_player.global_position = player_ref.global_position  # Position the sound at the player
	player_ref.add_child(smoke_player)  # Add it to the player node to ensure it's processed
	smoke_player.play()
	
	await get_tree().create_timer(2.0).timeout
	

func _apply_drinking_effect():
	print("Player starts drinking!")
	
	print(player_ref.bladder)
	player_ref.bladder += 200
	Global.update_piss_bar.emit(player_ref.bladder)
	
	Global.drinking.emit()
	
	var drinking_player = AudioStreamPlayer3D.new()
	drinking_player.stream = DRINKING_SOUND
	drinking_player.global_position = player_ref.global_position
	player_ref.add_child(drinking_player)
	drinking_player.play()
	
func _apply_snusing_effect():
	print("Player uses snus!")
	original_fov = player_ref.camera.fov
	
	Global.snusing.emit()
	
	var snus_player = AudioStreamPlayer3D.new()
	snus_player.stream = SNUS_SOUND
	snus_player.global_position = player_ref.global_position
	player_ref.add_child(snus_player)
	snus_player.play()
	
	var tween := create_tween()
	
	player_ref.snusM += 2.5
	tween.tween_property(player_ref.camera, "fov", 75 + 20, 1)

func _apply_pills_effect():
	print("Player gets pills!")
	player_ref.strength += 10
	print(player_ref.strength)
	
	Global.pills.emit()
	
	var pill_player = AudioStreamPlayer3D.new()
	pill_player.stream = PILL_SOUND
	pill_player.global_position = player_ref.global_position
	player_ref.add_child(pill_player)
	pill_player.play()
	
func _check_for_comboA():
	if power_ups.PowerUpType.SMOKING in collected_powerups and power_ups.PowerUpType.DRINKING in collected_powerups:
		_activate_combo0()
	elif power_ups.PowerUpType.SNUSING in collected_powerups and power_ups.PowerUpType.DRINKING in collected_powerups:
		_activate_combo1()
	elif power_ups.PowerUpType.PILLS in collected_powerups and power_ups.PowerUpType.DRINKING in collected_powerups:
		_activate_combo2()

func _activate_combo0():
	if !combo_active:
		combo_active = true
		combo_timer = combo_duration  # Reset combo timer
		print("Combo 1 activated!")
# Reset combo state after timer runs out

func _activate_combo1():
	if !combo_active:
		combo_active = true
		combo_timer = combo_duration  # Reset combo timer
		print("Combo 2 activated!")
# Reset combo state after timer runs out

func _activate_combo2():
	if !combo_active:
		combo_active = true
		combo_timer = combo_duration  # Reset combo timer
		print("Combo 3 activated!")
# Reset combo state after timer runs out
func _reset_combo():
	combo_active = false
	 # Reset combo effects here, if needed_
func clear_collected_powerups():
	print("Clearing collected power-ups...")
	
	if power_ups.PowerUpType.SNUSING in collected_powerups:
		var tween := create_tween()
		player_ref.snusM += 1
		tween.tween_property(player_ref.camera, "fov", original_fov, 1)
	
	collected_powerups.clear()  # Clear the list
	clear_timer = 0  # Reset the clear timer after clearing
	collected_p = false
	#rever
