extends Control

@export var image1 : Texture
@export var image2 : Texture
@export var image3 : Texture
@export var achievement_manager: Node
var canvas_layer : CanvasLayer

# Get references to the TextureRect nodes
var slots : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add all the TextureRect nodes to an array
	slots = [ $Slot1, $Slot2, $Slot3 ]
	
	# Connect a signal to detect clicks on the screen
	#set_process_input(true)

func _input(event:InputEvent):
	if event.is_action_pressed("leave_slot"):
		Global.player_ref.slot_machine = false
		Global.update_hud.emit()
		get_tree().paused = false
	
	if event.is_action_pressed("Slot_Machine"):
		# Randomly pick one of the 3 images for each slot when clicked
		randomize()
		
		for slot in slots:
			var random_choice = randi() % 3
			
			match random_choice:
				0:
					slot.texture = image1
				1:
					slot.texture = image2
				2:
					slot.texture = image3
		if check_if_all_match():
			print("All three images match!")
			achievement_manager.unlock_achievement("Lets Go Gambling", "win on the fruit machine")
			 
		else:
			print("Images do not match.")
					
func check_if_all_match() -> bool:
	if slots[0].texture == slots[1].texture and slots[1].texture == slots[2].texture:
		return true
	return false
