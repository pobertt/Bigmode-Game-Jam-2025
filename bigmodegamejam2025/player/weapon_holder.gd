extends Node3D

@onready var weapon_mesh: MeshInstance3D = $Weapon
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var particles: GPUParticles3D = $Weapon/PistolParticles3D

var pistol = preload("res://assets/weapons/new_weapons/new_pistol.res")
var shotgun = preload("res://assets/weapons/new_weapons/new_shotgun.res")

signal reload

func _ready() -> void:
	pass

func update_mesh(new_mesh : ArrayMesh):
	weapon_mesh.mesh = new_mesh

func set_particle(type):
	if type == Gun.GunType.PISTOL:
		print("pistol mesh particles")
		particles = $Weapon/PistolParticles3D
	elif type == Gun.GunType.SHOTGUN:
		print("shotgun mesh particles")
		particles = $Weapon/ShotgunParticles3D

func play_gun_anim(anim_name : String, speed_scale : float = 1):
	anim_player.stop() # Stop any current animation
	if anim_name == "recoil":
		particles.emitting = true
	
	anim_player.speed_scale = speed_scale # Set speed
	anim_player.play(anim_name) # Play set anim

func reload_finished():
	reload.emit()
