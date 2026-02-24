extends CanvasLayer

# ──────────────────────────────────────────────
#  item_menu.gd
#  Attach to a CanvasLayer node called ItemMenu.
#  Scene structure expected:
#
#  ItemMenu (CanvasLayer)
#  └── Panel
#      ├── TitleLabel      (Label)  - shows e.g. "Choose a Book"
#      ├── Button0         (Button) - first variant
#      ├── Button1         (Button) - second variant
#      └── Button2         (Button) - third variant
#
#  The Panel should start hidden (visible = false).
# ──────────────────────────────────────────────

@onready var panel:       Control = $Panel
@onready var title_label: Label   = $Panel/TitleLabel
@onready var buttons: Array = [
	$Panel/Button0,
	$Panel/Button1,
	$Panel/Button2,
]

# The item node currently being interacted with
var _current_item: Area2D = null


func _ready() -> void:
	panel.visible = false
	for i in range(buttons.size()):
		# Bind button index so we know which was pressed
		buttons[i].pressed.connect(_on_variant_chosen.bind(i))


## Called by tower.gd (or any item) when the player touches an item.
## Opens the menu and populates the choices.
func open_for_item(item_node: Area2D) -> void:
	_current_item = item_node
	var category: String = item_node.category
	var variants: Array = GameState.ITEM_VARIANTS[category].duplicate()

	title_label.text = "Choose a %s:" % category

	# Shuffle so the liked option isn't always in the same slot
	variants.shuffle()
	for i in range(buttons.size()):
		buttons[i].text = variants[i]

	panel.visible = true
	get_tree().paused = true   # Freeze game while menu is open


func _on_variant_chosen(button_index: int) -> void:
	if _current_item == null:
		return

	var category: String  = _current_item.category
	var chosen_variant: String = buttons[button_index].text

	# Register with GameState and get feedback
	var preference_level: String = GameState.register_item_choice(category, chosen_variant)

	# Show brief feedback text on the button before closing
	_show_feedback(button_index, preference_level)

	_current_item.mark_collected()
	_current_item = null

	# Close after a short delay so the player can see the feedback
	await get_tree().create_timer(0.8).timeout
	panel.visible = false
	get_tree().paused = false


func _show_feedback(button_index: int, preference_level: String) -> void:
	# Temporarily change button text to give emotional feedback
	match preference_level:
		"liked":
			buttons[button_index].text += "  ✓  She'll love it!"
		"neutral":
			buttons[button_index].text += "  –  She might like it."
		"disliked":
			buttons[button_index].text += "  ✗  Probably not her style..."
