extends Node

# Achievement class that stores info about each achievement
class Achievement:
	var name: String
	var description: String
	var triggered: bool = false

# A list of all achievements in the game
var achievements: Array = []
var achievement_hud: Control


# Signals for achievement events
signal achievement_unlocked(achievement: Achievement)


func _ready():
	# Load achievements (This could be done from a file or preset)
	
	achievements.append(Achievement.new())
	achievements[0].name = "Morning Routine"
	achievements[0].description = "Combo Smoking and drinking"
	
	achievements.append(Achievement.new())
	achievements[1].name = "Smoker's Delight"
	achievements[1].description = "Collect a smoking power-up!"
	
	achievements.append(Achievement.new())
	achievements[2].name = "sip happens"
	achievements[2].description = "Collect a drinking power-up!"
	
	achievements.append(Achievement.new())
	achievements[3].name = "I need a snus"
	achievements[3].description = "Collect a suns power-up!"
	
	achievements.append(Achievement.new())
	achievements[4].name = "When you have to go, you have to go"
	achievements[4].description = "Max out the piss meter"
	
	achievements.append(Achievement.new())
	achievements[5].name = "The world is my toilet"
	achievements[5].description = "Relieve yourself"
	
	achievements.append(Achievement.new())
	achievements[6].name = "My pain go away pills"
	achievements[6].description = "Collect a pill power-up!"
	
	achievements.append(Achievement.new())
	achievements[6].name = "Pick a struggle"
	achievements[6].description = "Collect all power-up types!"
	
	achievements.append(Achievement.new())
	achievements[7].name = "Lets Go Gambling"
	achievements[7].description = "win on the fruit machine"
	
	achievements.append(Achievement.new())
	achievements[8].name = "Grim Sleeper"
	achievements[8].description = "put 10 pound town residents to sleep"
	
	achievements.append(Achievement.new())
	achievements[7].name = "Pound town veteran"
	achievements[7].description = "reach 500 power"
	# Add more achievements as needed

func unlock_achievement(achievement_name: String, description: String):
	for achievement in achievements:
		if achievement.name == achievement_name and !achievement.triggered:
			achievement.triggered = true
			#emit_signal("achievement_unlocked", achievement)
			Global.achpopup.emit(achievement_name,description)
			print("Achievement unlocked: " + achievement.name)
