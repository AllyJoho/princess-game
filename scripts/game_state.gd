extends Node

var start_time: float = 0.0
var final_time: float = 0.0
var princess_preferences = [] # Array of Arrays [[1,2,3], [3,1,2], etc.]
var player_choices = [] # What the player actually picked

func _ready():
	generate_preferences()

func generate_preferences():
	for i in range(5):
		var prefs = [1, 2, 3]
		prefs.shuffle()
		princess_preferences.append(prefs)

func start_timer():
	start_time = Time.get_unix_time_from_system()

func stop_timer():
	final_time = Time.get_unix_time_from_system() - start_time
	
func game_end_message():
	if final_time == 0:
		return "Something strange happened..."
	else:
		return str(final_time)
	pass
