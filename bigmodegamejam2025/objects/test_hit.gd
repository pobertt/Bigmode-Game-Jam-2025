extends RigidBody3D
class_name DestructableObjects

@export var object_health : int = 100
@export var audio_hit : AudioStream
@export var audio_death : AudioStream
@export var obj_type : ObjectType = ObjectType.NORMAL

@export var explosion_force : float = 10
@export var max_explosion_dist = 15
@export var explosion_damage: float  = 10

@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var explosion_1: GPUParticles3D 
@onready var explosion_2: GPUParticles3D

@onready var keg_particle: GPUParticles3D

@export var anim_player: AnimationPlayer


enum ObjectType {
	NORMAL,
	EXPLOSIVE,
	CAT,
	KEG,
	VENDING_MACHINE,
	FOOD
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
			explosion_1.emitting = true
			explosion_2.emitting = true
			push_away_objects()

func _process(delta: float) -> void:
	if audio_stream_player.stream == audio_death && audio_stream_player.playing == false:
		self.queue_free()

func push_away_objects():
	for body in $Area3D.get_overlapping_bodies():
		var body_pos = body.global_position
		var force_div = 1.0
		if body is CharacterBody3D:
			body_pos.y += 4
			force_div = 4.0 # Character bodies have no mass
		elif body is RigidBody3D:
			force_div = max(0.01, body.mass)
		var force_dir = self.global_position.direction_to(body_pos)
		var body_dist = (body_pos - self.global_position).length()
		var explosion_vec = lerp(0.0, explosion_force, 1.0 - clampf((body_dist / max_explosion_dist), 0.0, 1.0)) / force_div * force_dir
		if body is RigidBody3D:
			body.apply_impulse(explosion_vec * explosion_force)
		elif body is CharacterBody3D:
			body.velocity = Vector3(body.velocity.x, (body.velocity.y + 1),body.velocity.z)
			body.velocity += explosion_vec * explosion_force
			if body.has_method("change_health"):
				body.change_health(explosion_damage)

func eaten():
	Global.pills.emit()
	await get_tree().create_timer(0.25).timeout
	self.queue_free()
