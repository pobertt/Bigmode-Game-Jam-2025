extends Node

enum PowerUpType {
	SMOKING,
	DRINKING,
	SNUSING,
	PILLS,
}

@onready var powerup_mesh: MeshInstance3D = $powerup_mesh
@export var power_up_type : PowerUpType
@onready var pick_up_sound: AudioStreamPlayer3D = $pick_up_sound

const SMOKE_SOUND = preload("res://SFX/dead.mp3")

const BOTTLE = preload("res://assets/misc_items/res/BOTTLE.res")
const CIG_PACK = preload("res://assets/misc_items/res/CIGS.res")
const PILLS = preload("res://assets/misc_items/res/PILLS.res")

signal collected(power_up_type)

func _ready():
	# Connect to the power-up signals
	connect("body_entered", Callable(self, "_on_body_entered"))
	if power_up_type == PowerUpType.SMOKING:
		powerup_mesh.mesh = CIG_PACK
		pick_up_sound.stream = SMOKE_SOUND
	elif power_up_type == PowerUpType.DRINKING:
		powerup_mesh.mesh = BOTTLE
	elif power_up_type == PowerUpType.SNUSING:
		powerup_mesh.mesh = BOTTLE
	elif power_up_type == PowerUpType.PILLS:
		powerup_mesh.mesh = PILLS
	
# FUNCTION FOR WHEN THE PLAYER ENTERS THE POWER UP AREA
func _on_body_entered(body):
	if body.is_in_group("player"):  
		emit_signal("collected", power_up_type) 
		pick_up_sound.play() 
		queue_free() 
		print("collected")

func _process(delta: float) -> void:
	powerup_mesh.rotation.y += 1 * delta
