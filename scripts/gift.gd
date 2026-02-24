extends Area2D

var index: int = -1

func _ready():
	$CanvasLayer/OptionBox.visible = false

func pause():
	get_tree().paused = true
	show()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Knight":
		make_options()

func make_options():
	var catagory = GameState.ITEM_NAMES[index]
	var message = "What type of "+catagory+" do you want to get the princess?"
	$CanvasLayer/OptionBox/Options/Message.text = message
	$CanvasLayer/OptionBox/Options/option1.text = GameState.ITEM_VARIANTS.catagory[0]
	$CanvasLayer/OptionBox/Options/option2.text = GameState.ITEM_VARIANTS.catagory[1]
	$CanvasLayer/OptionBox/Options/option3.text = GameState.ITEM_VARIANTS.catagory[2]
	pause()

func enter_option(option):
	GameState.player_choices[index] = option
	get_tree().paused = false
	self.queue_free()


func _on_option_1_pressed() -> void:
	enter_option(1)


func _on_option_2_pressed() -> void:
	enter_option(2)


func _on_option_3_pressed() -> void:
	enter_option(3)
