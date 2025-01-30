extends RigidBody3D
class_name DestructableObjects

@export var object_health : int = 100
@onready var mesh: MeshInstance3D = $mesh

func change_health(damage):
	object_health -= damage
	
	print(object_health, " enemy hit")
	
	apply_central_impulse(-Global.player_ref.basis.z * 5.0)
	#apply_central_impulse(Global.player_ref.basis.y * 2.0)
	#apply_central_impulse(Global.player_ref.basis.x * 2.0)
	
	if object_health <= 0:
		self.queue_free()
