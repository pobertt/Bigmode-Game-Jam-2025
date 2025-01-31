extends Node3D

@onready var interactable_area: Area3D = $Interactable_Area

func _ready() -> void:
	Global.on_interact.connect(_on_interact)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("interact"):
		body.interact()

func _on_body_exited(body: Node3D) -> void:
	pass

func _on_interact():
	print("_on_interact")
