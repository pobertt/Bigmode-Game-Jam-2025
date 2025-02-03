extends Node3D

const IDLE = preload("res://SFX/NPC/Guy1/Idle.wav")
const BAZINGA = preload("res://SFX/player/Bazinga.wav")
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
const SNORT = preload("res://SFX/player/Snort.wav")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var animarray = ["backflip", "floating", "flying", "fnafjumpscare", "kickingfeet", "sexydance", "tpose"]
	$AnimationPlayer.play(animarray[randi_range(0, animarray.size() - 1)])

func change_health(damage):
	print("called")
	var dmg = damage
	var random_sounds = [IDLE]
	audio_player.stream = random_sounds[randi_range(0, random_sounds.size() - 1)]
	audio_player.play()
