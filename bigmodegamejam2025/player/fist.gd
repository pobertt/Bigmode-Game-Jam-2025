extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area3D = $fist_mesh/hitbox

var fist_damage : int = 20

func _process(delta: float) -> void:
	if Input.is_action_pressed("fist"):
		anim_player.play("punch")
		hitbox.monitoring = true

func _on_animation_player_animation_finished(anim_name):
	anim_player.play("idle")
	hitbox.monitoring = false

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		body.change_health(fist_damage)
