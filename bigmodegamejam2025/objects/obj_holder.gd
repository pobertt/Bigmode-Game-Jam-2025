extends Node3D

@onready var beer: MeshInstance3D = $Beer
@onready var lighter: MeshInstance3D = $Lighter
@onready var blunt: MeshInstance3D = $Blunt
@onready var pills: MeshInstance3D = $Pills
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var snus: Node3D = $snusgordic

var obj_enum = PowerUps.PowerUpType

func _ready() -> void:
	Global.lighting.connect(lighting_blunt)
	Global.drinking.connect(drinking_beer)
	Global.snusing.connect(taking_snus)
	Global.pills.connect(taking_pills)

func lighting_blunt():
	print("lighting")
	obj_enum = PowerUps.PowerUpType.SMOKING
	blunt.visible = true
	lighter.visible = true
	pills.visible = false
	beer.visible = false
	snus.visible = false
	anim_player.play("lighting_blunt")

func drinking_beer():
	print("drinking beer")
	obj_enum = PowerUps.PowerUpType.DRINKING
	blunt.visible = false
	lighter.visible = false
	pills.visible = false
	snus.visible = false
	beer.visible = true
	anim_player.play("drinking")

func taking_snus():
	print("snus destroyer")
	obj_enum = PowerUps.PowerUpType.SNUSING
	snus.visible = true
	blunt.visible = false
	lighter.visible = false
	beer.visible = false
	pills.visible = false
	anim_player.play("snus")

func taking_pills():
	print("pill lover")
	obj_enum = PowerUps.PowerUpType.PILLS
	blunt.visible = false
	lighter.visible = false
	beer.visible = false
	snus.visible = false
	pills.visible = true
	anim_player.play("pills")

func animation_finished(anim_name: StringName) -> void:
	if obj_enum == PowerUps.PowerUpType.SMOKING:
		blunt.visible = false
		lighter.visible = false
	if obj_enum == PowerUps.PowerUpType.DRINKING:
		beer.visible = false
	if obj_enum == PowerUps.PowerUpType.PILLS:
		pills.visible = false
		
