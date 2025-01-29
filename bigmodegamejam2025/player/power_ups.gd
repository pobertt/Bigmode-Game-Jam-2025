extends Node

enum PowerUpType {
	SMOKING,
	DRINKING,
	SNUSING,
	CAR_KEYS
}


@export var power_up_type : PowerUpType

signal collected(power_up_type)

func _ready():
	# Connect to the power-up signals
	connect("body_entered", Callable(self, "_on_body_entered"))
	

# FUNCTION FOR WHEN THE PLAYER ENTERS THE POWER UP AREA
func _on_body_entered(body):
	if body.is_in_group("player"):  
		emit_signal("collected", power_up_type)  
		queue_free() 
		print("collected")
