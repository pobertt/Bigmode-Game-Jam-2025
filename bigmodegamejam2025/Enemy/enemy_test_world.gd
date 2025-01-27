extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var playerref = $Player

# Provides players current world position and sends it to the enemy
func _process(delta: float) -> void:
	pass
	#get_tree().call_group("enemy", "target_position", playerref.global_transform.origin)
