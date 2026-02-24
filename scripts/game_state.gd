extends Node

# ──────────────────────────────────────────────
#  GameState  (Autoload Singleton)
#  Add via: Project > Project Settings > Autoload
#  Name it exactly:  GameState
# ──────────────────────────────────────────────

# Item categories (indices match ITEM_NAMES order)
const ITEM_NAMES = ["Flower", "Weapon", "Book", "Chocolate", "Gem"]

# Variants for each category  [liked, neutral, disliked]  will be shuffled per game
const ITEM_VARIANTS = {
	"Flower":    ["Rose", "Tulip", "Daisy"],
	"Weapon":    ["Bow", "Dagger", "Poison"],
	"Book":      ["Romance", "Fantasy", "History"],
	"Chocolate": ["Dark", "Milk", "Caramel"],
	"Gem":       ["Ruby", "Sapphire", "Emerald"],
}

# Score values for each preference level
const SCORE_LIKED     =  2
const SCORE_NEUTRAL   =  0
const SCORE_DISLIKED  = -1

# Outcome thresholds
# Win  : all 5 items chosen are the princess's liked variant
# Retry: at least one liked item (score > 0)
# Over : score <= 0

# ── Persistent state (survives retries, resets on game over / new game) ──
var princess_preferences: Dictionary = {}
# e.g. { "Flower": { "liked": "Rose", "neutral": "Tulip", "disliked": "Daisy" } }

var attempt_number: int = 0
var revealed_hints: Array = []   # hints the dragon has already given

# ── Per-attempt state (resets each climb) ──
var current_score: int = 0
var items_collected: Dictionary = {}
# e.g. { "Flower": "Rose", "Book": "Fantasy" }
var liked_count: int = 0   # how many of this attempt's picks were liked


# ────────────────────────────────────────────
#  Initialisation
# ────────────────────────────────────────────

func _ready() -> void:
	new_game()


## Call this to fully reset everything (new game or after game over)
func new_game() -> void:
	attempt_number = 0
	revealed_hints = []
	_generate_preferences()
	reset_attempt()


## Generates a fresh random set of princess preferences
func _generate_preferences() -> void:
	princess_preferences.clear()
	for category in ITEM_VARIANTS:
		var variants = ITEM_VARIANTS[category].duplicate()
		variants.shuffle()
		princess_preferences[category] = {
			"liked":     variants[0],
			"neutral":   variants[1],
			"disliked":  variants[2],
		}


# ────────────────────────────────────────────
#  Per-Attempt helpers
# ────────────────────────────────────────────

## Resets score and collected items for a new climb
func reset_attempt() -> void:
	attempt_number += 1
	current_score = 0
	items_collected.clear()
	liked_count = 0


## Called when the player picks a variant for a category.
## Returns the preference level as a String: "liked" | "neutral" | "disliked"
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

## Evaluates the outcome based on the current attempt's score / liked count
func evaluate_outcome() -> Outcome:
	if liked_count == ITEM_NAMES.size():
		return Outcome.WIN
	elif current_score > 0:
		return Outcome.RETRY
	else:
		return Outcome.GAME_OVER


# ────────────────────────────────────────────
#  Hint generation
# ────────────────────────────────────────────

## Returns a single vague, poetic hint String for this attempt.
## Cycles through all 5 categories before repeating.
func get_hint_for_attempt() -> String:
	var unrevealed = []
	for cat in ITEM_NAMES:
		if not (cat in revealed_hints):
			unrevealed.append(cat)

	# If we've cycled through all categories, start over
	if unrevealed.is_empty():
		unrevealed = ITEM_NAMES.duplicate()
		revealed_hints.clear()

	unrevealed.shuffle()
	var category = unrevealed[0]
	revealed_hints.append(category)

	return _make_vague_hint(category)


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