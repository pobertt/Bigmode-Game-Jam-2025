extends Node3D

@onready var p_particle: GPUParticles3D = $"3dparticle"
@onready var piss_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var splash: GPUParticles3D = $splash

# Called every frame. 'delta' is the elapsed time since the previous frame.
func piss() -> void:
	if Global.player_ref.piss == true:
		p_particle.emitting = true
		splash.emitting = true
		piss_sound.play()
	else:
		p_particle.emitting = false
		splash.emitting = false
		piss_sound.stop()
