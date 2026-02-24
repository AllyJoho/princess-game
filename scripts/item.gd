extends Area2D

# ──────────────────────────────────────────────
#  item.gd
#  Attach to each item node in the scene.
#  The item node should be an Area2D with:
#    - CollisionShape2D  (the pickup trigger)
#    - Sprite2D          (the item icon)
#    - Label             (optional floating label showing category)
# ──────────────────────────────────────────────

## Set this in the editor (or by tower.gd when spawning) to one of:
## "Flower" | "Weapon" | "Book" | "Chocolate" | "Gem"
@export var category: String = "Flower"

## Whether this item has already been collected this attempt
var collected: bool = false

# Emitted when the player steps into this item's area
# The ItemMenu listens to this signal
signal item_touched(item_node: Area2D)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	# Only react to the player, and only if not already collected
	if collected:
		return
	if not body.is_in_group("player"):
		return

	collected = true
	emit_signal("item_touched", self)


## Called by ItemMenu after the player makes their choice.
## Hides the item sprite so it looks collected.
func mark_collected() -> void:
	# Hide the visual but keep the node around (easier than freeing mid-signal)
	visible = false
	set_deferred("monitoring", false)