extends Area2D

# ──────────────────────────────────────────────
#  gift.gd  (fixed)
#  Fixes:
#   - ITEM_VARIANTS.catagory  →  ITEM_VARIANTS[category]  (typo + wrong syntax)
#   - GameState.player_choices  →  GameState.register_item_choice()
#   - Option box now shown/hidden properly
#   - Game unpaused after choice
# ──────────────────────────────────────────────

var index: int = -1

func _ready():
	$CanvasLayer/OptionBox.visible = false


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Knight":
		make_options()


func make_options():
	var category = GameState.ITEM_NAMES[index]
	var variants = GameState.ITEM_VARIANTS[category]   # fixed: was .catagory (typo + wrong syntax)

	var message = "What type of " + category + " do you want to get the princess?"
	$CanvasLayer/OptionBox/Options/Message.text = message
	$CanvasLayer/OptionBox/Options/option1.text = variants[0]
	$CanvasLayer/OptionBox/Options/option2.text = variants[1]
	$CanvasLayer/OptionBox/Options/option3.text = variants[2]

	$CanvasLayer/OptionBox.visible = true
	get_tree().paused = true


func enter_option(variant: String):
	var category = GameState.ITEM_NAMES[index]
	var preference_level = GameState.register_item_choice(category, variant)  # fixed: was player_choices

	print("Gave princess a ", variant, " (", category, ") — she ", preference_level, " it.")

	$CanvasLayer/OptionBox.visible = false
	get_tree().paused = false
	queue_free()


func _on_option_1_pressed() -> void:
	print("option1")
	enter_option($CanvasLayer/OptionBox/Options/option1.text)


func _on_option_2_pressed() -> void:
	print("option1")
	enter_option($CanvasLayer/OptionBox/Options/option2.text)


func _on_option_3_pressed() -> void:
	print("option1")
	enter_option($CanvasLayer/OptionBox/Options/option3.text)
