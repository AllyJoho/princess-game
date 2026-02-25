extends Control

func _ready():
	get_tree().paused = false
	hide()

func resume():
	get_tree().paused = false
	hide()

func pause():
	if GameState.pause_enabled:
		get_tree().paused = true
		show()

func testEsc():
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		print("pause")
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()



func _on_resume_pressed() -> void:
	resume() 


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit() 

func _process(_delta: float) -> void:
	testEsc() 
