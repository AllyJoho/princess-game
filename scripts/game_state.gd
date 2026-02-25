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
var intro_played: bool = false

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
	intro_played   = false
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
	elif items_collected.size() == 0 or liked_count == 0 and current_score < 0:
		return Outcome.GAME_OVER
	else:
		return Outcome.RETRY


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

func generate_retry_dialogue() -> Array:
	var liked_lines  : Array = []
	var fine_lines  : Array = []
	var hated_lines  : Array = []
	var any_liked    : bool  = false

	for category in ITEM_NAMES:
		if not items_collected.has(category):
			continue
		var variant : String = items_collected[category]
		var prefs            = princess_preferences[category]
		if variant == prefs["liked"]:
			any_liked = true
			var text: String
			match category:
				"Flower":    text = "A %s! You actually brought me a %s. They're my favorite. I have some in my garden you know." % [variant, variant]
				"Weapon":    text = "You chose a %s. There's something about it... you know I trained to use this right? Watch out :/)" % variant
				"Book":      text = "A %s book. I love that genere. It's sort of like my life... if you think about it." % variant
				"Chocolate": text = "%s chocolate. My favourite. I sneak it from the kitchen sometimes you know?" % variant
				"Gem":       text = "A %s. I love the color! Very sparkly." % variant
				_:           text = "The %s — yes. That one I liked." % variant
			liked_lines.append({"speaker": "Princess", "text": text})
		elif variant == prefs["disliked"]:
			var text: String
			match category:
				"Flower":    text = "I don't even want to talk about the flower."
				"Weapon":    text = "That... weapon choice. Let's not discuss it."
				"Book":      text = "The book was not to my taste. At all."
				"Chocolate": text = "I'm not saying anything about the chocolate."
				"Gem":       text = "The gem was... a choice."
				_:           text = "The %s. No." % category
			hated_lines.append({"speaker": "Princess", "text": text})
		else:
			var text: String
			match category:
				"Flower":    text = "The flower was fine. Just fine."
				"Weapon":    text = "The weapon was acceptable, I suppose. I don't know how to use it but I do think violence is a solution."
				"Book":      text = "The book was fine. I don't know if I'll read it but you put an effort."
				"Chocolate": text = "The chocolate was... fine. It's juse not me, you know?"
				"Gem":       text = "The gem was okay. Sparkles are always fun."
				_:           text = "The %s was fine." % category
			fine_lines.append({"speaker": "Princess", "text": text})

	# Build result: liked first, then others, capped at 3 lines
	var result: Array = []
	for l in hated_lines:
		if result.size() < 3:
			result.append(l)
	for l in liked_lines:
		if result.size() < 3:
			result.append(l)
	for l in fine_lines:
		if result.size() < 3:
			result.append(l)
	if attempt_number > 2 and current_score > 3:
		result.append({"speaker": "Princess", "text": "You do keep coming for me... am I that worth it to you?"})
	var dragon_line: String
	if any_liked:
		dragon_line = "She didn't have me eat you. Progress."
	else:
		dragon_line = "Well. At least you tried. Mostly."
	result.append({"speaker": "Dragon", "text": dragon_line})

	return result


func _make_vague_hint(category: String) -> String:
	var liked: String = princess_preferences[category]["liked"]
	match category:
		"Flower":
			return "She once told me her garden speaks to her soul... I believe she prefers %s." % liked
		"Weapon":
			return "The princess has particular tastes in danger... something about a %s." % liked
		"Book":
			return "I've seen her reading by candlelight. Always reaching for %s stories." % liked
		"Chocolate":
			return "She has strong opinions about sweets... specifically %s chocolate." % liked
		"Gem":
			return "She once cried over a gemstone. A %s, if I recall." % liked
		_:
			return "She mentioned something about %s once. A %s, specifically." % [category, liked]
