extends Control

@onready var ammo_count_label: Label = $AmmoCount_Label
@onready var health_count_label: Label = $HealthCount_Label
@onready var piss_label: Label = $Control/Piss_Label
@onready var piss_bar: ProgressBar = $Control/ProgressBar

func _ready() -> void:
	Global.update_hud.connect(_on_update_hud)
	Global.update_piss_bar.connect(_on_update_piss_bar)
	Global.decrease_piss_bar.connect(_on_decrease_piss_bar)

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

func _on_update_piss_bar(piss_amount):
	piss_bar.value += 200
	
	if piss_amount > 0:
		piss_label.visible = true
		piss_bar.visible = true

func _on_decrease_piss_bar(piss_amount):
	piss_bar.value = piss_amount
	if piss_amount == 0:
		piss_label.visible = false
		piss_bar.visible = false
