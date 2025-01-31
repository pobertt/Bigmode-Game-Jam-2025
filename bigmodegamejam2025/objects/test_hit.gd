extends RigidBody3D
class_name DestructableObjects

@export var object_health : int = 100
@export var audio_hit : AudioStream
@export var audio_death : AudioStream
@export var obj_type : ObjectType = ObjectType.NORMAL

@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var explosion_1: GPUParticles3D 
@onready var explosion_2: GPUParticles3D

enum ObjectType {
	NORMAL,
	EXPLOSIVE,
}

func change_health(damage):
	object_health -= damage
	audio_stream_player.stream = audio_hit
	audio_stream_player.play()
	
	print(object_health, " enemy hit")
	
	apply_central_impulse(-Global.player_ref.basis.z * 5.0)
	#apply_central_impulse(Global.player_ref.basis.y * 2.0)
	#apply_central_impulse(Global.player_ref.basis.x * 2.0)
	
	if object_health <= 0:
		audio_stream_player.stream = audio_death
		
		var a = get_child(0)
		var b = get_child(1)
		b.queue_free()
		a.queue_free()
		audio_stream_player.play()
		if obj_type == ObjectType.EXPLOSIVE:
			print("explosive")
			explosion_1.emitting = true
			explosion_2.emitting = true
		
func _process(delta: float) -> void:
	if audio_stream_player.stream == audio_death && audio_stream_player.playing == false:
		self.queue_free()
