extends Node

var pause_enabled: bool = false

var start_time: float = 0.0
var final_time: float = 0.0

func start_timer() -> void:
	start_time = Time.get_unix_time_from_system()

func stop_timer() -> void:
	final_time = Time.get_unix_time_from_system() - start_time

func game_end_message() -> String:
	if final_time == 0.0:
		return "Something strange happened..."
	return str(snapped(final_time, 0.01)) + "s"

# Item categories
const ITEM_NAMES = ["Flower", "Weapon", "Book", "Chocolate", "Gem"]

const ITEM_VARIANTS = {
	"Flower":    ["Rose", "Tulip", "Daisy"],
	"Weapon":    ["Bow", "Dagger", "Poison"],
	"Book":      ["Romance", "Fantasy", "History"],
	"Chocolate": ["Dark", "Milk", "Caramel"],
	"Gem":       ["Ruby", "Sapphire", "Emerald"],
}

const SCORE_LIKED     =  2
const SCORE_NEUTRAL   =  0
const SCORE_DISLIKED  = -1

# ── Persistent state ──
var princess_preferences: Dictionary = {}
var attempt_number: int = 0
var revealed_hints: Array = []

# ── Per-attempt state ──
var current_score: int = 0
var items_collected: Dictionary = {}
var liked_count: int = 0

# ── Stored hint for the next attempt (set by princess.gd, read by tower.gd) ──
var pending_hint: String = ""


# ────────────────────────────────────────────
#  Initialisation
# ────────────────────────────────────────────

func _ready() -> void:
	new_game()

func new_game() -> void:
	attempt_number = 0
	revealed_hints = []
	final_time     = 0.0
	pending_hint   = ""
	_generate_preferences()
	reset_attempt()

func _generate_preferences() -> void:
	princess_preferences.clear()
	for category in ITEM_VARIANTS:
		var variants = ITEM_VARIANTS[category].duplicate()
		variants.shuffle()
		princess_preferences[category] = {
			"liked":    variants[0],
			"neutral":  variants[1],
			"disliked": variants[2],
		}


# ────────────────────────────────────────────
#  Per-Attempt helpers
# ────────────────────────────────────────────

func reset_attempt() -> void:
	attempt_number += 1
	current_score   = 0
	items_collected.clear()
	liked_count     = 0

func register_item_choice(category: String, variant: String) -> String:
	items_collected[category] = variant
	var prefs = princess_preferences[category]
	var level: String
	if variant == prefs["liked"]:
		level = "liked"
		current_score += SCORE_LIKED
		liked_count += 1
	elif variant == prefs["neutral"]:
		level = "neutral"
		current_score += SCORE_NEUTRAL
	else:
		level = "disliked"
		current_score += SCORE_DISLIKED
	return level


# ────────────────────────────────────────────
#  Outcome evaluation
# ────────────────────────────────────────────

enum Outcome { WIN, RETRY, GAME_OVER }

func evaluate_outcome() -> Outcome:
	
	if liked_count == ITEM_NAMES.size():
		return Outcome.WIN
	elif current_score > 0:
		return Outcome.RETRY
	else:
		return Outcome.GAME_OVER


# ────────────────────────────────────────────
#  Hint generation
#  princess.gd calls prepare_hint_for_retry() BEFORE reloading.
#  tower.gd reads pending_hint on _ready() so there's no double-call.
# ────────────────────────────────────────────

func prepare_hint_for_retry() -> void:
	pending_hint = _pick_hint()

func consume_pending_hint() -> String:
	var h = pending_hint
	pending_hint = ""
	return h

func _pick_hint() -> String:
	var unrevealed = []
	for cat in ITEM_NAMES:
		if not (cat in revealed_hints):
			unrevealed.append(cat)
	if unrevealed.is_empty():
		unrevealed = ITEM_NAMES.duplicate()
		revealed_hints.clear()
	unrevealed.shuffle()
	var category = unrevealed[0]
	revealed_hints.append(category)
	return _make_vague_hint(category)

# Keep old name as a passthrough so nothing else breaks
func get_hint_for_attempt() -> String:
	if pending_hint != "":
		return consume_pending_hint()
	return _pick_hint()

func _make_vague_hint(category: String) -> String:
	match category:
		"Flower":
			return "She once told me her garden speaks to her soul... not every bloom deserves her windowsill."
		"Weapon":
			return "The princess has... particular tastes in danger. Choose wisely, brave knight."
		"Book":
			return "I've seen her reading by candlelight. She's very selective about her stories."
		"Chocolate":
			return "She has strong opinions about sweets. Strong enough to mention to a dragon, if you can imagine."
		"Gem":
			return "She once cried over a gemstone. I won't say which one. Or why."
		_:
			return "She mentioned something about %s once. I wasn't really listening." % category
