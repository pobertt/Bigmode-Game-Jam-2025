extends Node

@export var parent : CharacterBody3D
@onready var cooldown_timer: Timer = $CooldownTimer

var current_gun : Gun

func shoot():
	current_gun = parent.current_gun
