extends CanvasLayer

# ──────────────────────────────────────────────
#  cutscene.gd
#  Attach to a CanvasLayer node called Cutscene.
#  Scene structure expected:
#
#  Cutscene (CanvasLayer)
#  └── Panel
#      ├── DialogueLabel   (RichTextLabel)  - displays the current line
#      └── ContinueLabel   (Label)          - "Press Space to continue" prompt
#
#  Panel starts hidden.
# ──────────────────────────────────────────────

@onready var panel:           Control        = $Panel
@onready var dialogue_label:  RichTextLabel  = $Panel/DialogueLabel
@onready var continue_label:  Label          = $Panel/ContinueLabel

# Speaker colour codes
const COLOR_DRAGON   = "#00cc44"   # green
const COLOR_PRINCESS = "#ff88bb"   # pink
const COLOR_KNIGHT   = "#aaaaaa"   # grey

# Emitted when the full dialogue sequence finishes
signal dialogue_finished

var _lines: Array  = []   # Array of { "speaker": String, "text": String }
var _current_index: int = 0
var _waiting_for_input: bool = false


func _ready() -> void:
	panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _waiting_for_input:
		return
	if event.is_action_just_pressed("ui_accept") or event.is_action_just_pressed("jump"):
		_advance()


# ────────────────────────────────────────────
#  Public API
# ────────────────────────────────────────────

## Start a cutscene with an array of dialogue lines.
## Each line is a Dictionary: { "speaker": "Dragon"|"Princess"|"Knight", "text": "..." }
## Example:
##   Cutscene.play_dialogue([
##       { "speaker": "Dragon",   "text": "Why hello, brave Knight!" },
##       { "speaker": "Knight",   "text": "I am here to rescue the princess!" },
##   ])
func play_dialogue(lines: Array) -> void:
	_lines = lines
	_current_index = 0
	panel.visible = true
	get_tree().paused = true
	_show_line(_current_index)


## Build a line dictionary — convenience helper so callers don't
## have to remember the key names.
static func line(speaker: String, text: String) -> Dictionary:
	return { "speaker": speaker, "text": text }


# ────────────────────────────────────────────
#  Internal helpers
# ────────────────────────────────────────────

func _show_line(index: int) -> void:
	if index >= _lines.size():
		_finish()
		return

	var entry    = _lines[index]
	var speaker: String = entry["speaker"]
	var text: String    = entry["text"]
	var color: String   = _color_for_speaker(speaker)

	dialogue_label.bbcode_enabled = true
	dialogue_label.text = "[color=%s][b]%s[/b]\n%s[/color]" % [color, speaker, text]

	continue_label.visible = true
	_waiting_for_input = true


func _advance() -> void:
	_waiting_for_input = false
	continue_label.visible = false
	_current_index += 1
	_show_line(_current_index)


func _finish() -> void:
	panel.visible = false
	get_tree().paused = false
	emit_signal("dialogue_finished")


func _color_for_speaker(speaker: String) -> String:
	match speaker:
		"Dragon":   return COLOR_DRAGON
		"Princess": return COLOR_PRINCESS
		"Knight":   return COLOR_KNIGHT
		_:          return "#ffffff"


# ────────────────────────────────────────────
#  Pre-written dialogue sequences
#  Call these from princess.gd or tower.gd
# ────────────────────────────────────────────

## The opening cutscene when the game first starts
func play_intro() -> void:
	play_dialogue([
		line("Dragon", "Why hello, brave Knight! Have you come to rescue the princess?"),
		line("Dragon", "I hear the King is offering her hand to anyone who can save her!"),
		line("Dragon", "Ha! Any fool can save the princess!"),
		line("Dragon", "Now, I've talked to the princess and we've devised... a plan."),
		line("Dragon", "If you don't win her heart by the time you get up there, I'll eat you!"),
		line("Dragon", "I'll tell her you're on your way!"),
	])


## Dragon hint after a retry. Pass in the single hint string from GameState.
func play_retry_hints(hint: String, attempt: int) -> void:
	var encouragement: String
	match attempt:
		2: encouragement = "She must like you a little, or I'd have had a snack already."
		3: encouragement = "You're persistent. She mentioned that. I think positively."
		4: encouragement = "Fourth time's the charm. Probably. I don't actually know that saying."
		_: encouragement = "Still alive! That's honestly impressive at this point."

	play_dialogue([
		line("Dragon", "Ah, back again! Don't worry, she only pushed you off — that's practically flirting."),
		line("Dragon", encouragement),
		line("Dragon", hint),
		line("Knight", "Right. I'll try again."),
		line("Dragon", "That's the spirit! Up you go."),
	])


## Win ending
func play_win() -> void:
	play_dialogue([
		line("Princess", "Oh my... you actually remembered everything I like."),
		line("Princess", "I... I think I might be falling for you."),
		line("Knight", "Then let's go. Together."),
		line("Dragon", "...I'm not crying. There's smoke in my eyes."),
		line("Dragon", "Go on then. You've earned it."),
	])


## Retry ending — princess pushes knight off
func play_retry_ending() -> void:
	play_dialogue([
		line("Princess", "Hmm. You tried. Sort of."),
		line("Princess", "I'm not impressed enough to marry you, but... you're not terrible."),
		line("Princess", "Come back when you actually know me."),
		line("Knight", "I — wait —"),
		line("Dragon", "She pushed him off. Classic. I'll go retrieve him."),
	])


## Game over — dragon eats the knight
func play_game_over() -> void:
	play_dialogue([
		line("Princess", "...You brought me nothing? Nothing at all?"),
		line("Princess", "I'm going back inside."),
		line("Dragon", "Well. A deal's a deal."),
		line("Dragon", "Don't worry. I'm sure you were very brave."),
		line("Dragon", "Mostly."),
	])
