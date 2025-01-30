extends RigidBody3D
class_name DestructableObjects

@export var object_health : int = 100


func change_health(damage):
	object_health -= damage
	
	print(object_health, " enemy hit")
	
	apply_central_impulse(-Global.player_ref.basis.z * 2.0)
	apply_central_impulse(Global.player_ref.basis.y * 2.0)
	apply_central_impulse(Global.player_ref.basis.x * 2.0)
	
	if object_health <= 0:
		self.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
