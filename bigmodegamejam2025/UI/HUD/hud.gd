extends Control


@onready var piss_label: Label = $Piss_Control/Piss_Label
@onready var piss_bar: ProgressBar = $Piss_Control/ProgressBar
@onready var interact_label: Label = $Interaction/InteractLabel
@onready var gameover: Control = $Gameover
@onready var health_count_label: Label = $Control/HealthCount_Label
@onready var ammo_count_label: Label = $Control2/AmmoCount_Label
@onready var kill_count_label: Label = $KillCountLabel
@onready var power_label: Label = $POWERLabel
@onready var slot_ui: Control = $SlotUI



var paused : bool 
var achievement_panel: Panel
@export var achievement: Node
@onready var achievement_label: Label = $Control4/Label


func _ready() -> void:
	Global.update_hud.connect(_on_update_hud)
	Global.update_piss_bar.connect(_on_update_piss_bar)
	Global.decrease_piss_bar.connect(_on_decrease_piss_bar)
	Global.update_interact.connect(_on_update_interact)
	Global.achpopup.connect(_on_update_achievement)
	
	

func _on_update_hud():
		
	var player : CharacterBody3D = Global.player_ref
	
	# Ammo Count Visibility
	if player.current_gun.type == Gun.GunType.MELEE:
		ammo_count_label.visible = false
	else:
		ammo_count_label.visible = true
	
	# Set Label
	ammo_count_label.text = "%s / %s" % [player.current_bullets, player.ammo[player.current_gun.ammo]]
	# player health is basically the same way
	health_count_label.text = "%s" % player.health
	
	kill_count_label.text = "Kill Count: %s" % player.killcount
	
	power_label.text = "POWER: %s" % player.strength
	
	
	if player.health <= 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		gameover.visible = true
		player.health = 100
	elif player.health >= 100 and Global.unpause == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().change_scene_to_file("res://map/world.tscn")
		gameover.visible = false
	
	if player.slot_machine == true:
		slot_ui.visible = true
	else: 
		slot_ui.visible = false

func _on_update_piss_bar(piss_amount, keg_used):
	print("updating piss")
	if keg_used == true:
		piss_bar.value += piss_amount
	else:
		piss_bar.value += 200
	
	
	if piss_amount > 0:
		piss_label.visible = true
		piss_bar.visible = true

func _on_decrease_piss_bar(piss_amount):
	piss_bar.value = piss_amount
	if piss_amount == 0:
		piss_label.visible = false
		piss_bar.visible = false

func _on_update_interact():
	if Global.can_interact == true:
		interact_label.show()
	else:
		interact_label.hide()
func _on_update_achievement(name,desc):
	$Control4.visible=true
	achievement_label.text = "%s: %s" % [name,desc]
	await get_tree().create_timer(5).timeout
	$Control4.visible=false
