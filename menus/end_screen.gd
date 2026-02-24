extends Control

func _ready():
	get_tree().paused = false
	hide()

func resume():
	get_tree().paused = false
	hide()

func pause():
	get_tree().paused = true
	show()

func on_game_end() -> void:
	pause()
	$PanelContainer/VBoxContainer/Message.text = GameState.game_end_message()

func _on_try_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_give_up_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
