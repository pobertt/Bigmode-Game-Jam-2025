extends Node3D

@onready var skeleton_3d: Skeleton3D = $Armature/Skeleton3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_health(damage):
	print("hit")
	$Armature/Skeleton3D.physical_bones_start_simulation()
	for child in Global.player_ref.get_children():
		if child.name == "GunSystem":
			var raycast = child.get_bullet_raycasts()
			for cast in raycast:
				var bones = skeleton_3d.get_bone_count()
				for bone in bones:
					if bone.get_child(0) == cast["hit_target"]:
						print("Hit" + str(cast["hit_target"]))
				
				
				
