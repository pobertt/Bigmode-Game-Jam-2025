extends Node



func play_sfx(sound : AudioStream, parent, distance : int = 0, volume_gain : int = 0):
	var audioplayer : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audioplayer.stream = sound
	audioplayer.max_distance = distance
	audioplayer.volume_db = volume_gain
	audioplayer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	#When sound is done, delete player
	audioplayer.connect("finished", audioplayer.queue_free)
	#Add player to child
	parent.add_child(audioplayer)
	
	#Play sound
	audioplayer.play()
