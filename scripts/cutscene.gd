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

signal dialogue_finished

var _lines: Array  = []
var _current_index: int = 0
var _waiting_for_input: bool = false


func _ready() -> void:
	panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _waiting_for_input:
		return
	if not (event is InputEventKey or event is InputEventJoypadButton):
		return

	var should_advance = false

	# Check all mapped actions that should advance dialogue
	if event.is_action_just_pressed("jump"):
		should_advance = true
	elif event.is_action_just_pressed("ui_accept"):
		should_advance = true
	elif event.is_action_just_pressed("ui_select"):
		should_advance = true
	# Direct key fallback — catches Space even if action mapping is consumed
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_SPACE \
		or event.physical_keycode == KEY_ENTER \
		or event.physical_keycode == KEY_KP_ENTER:
			should_advance = true

	if should_advance:
		get_viewport().set_input_as_handled()  # prevent input leaking to player
		_advance()


# ────────────────────────────────────────────
#  Public API
# ────────────────────────────────────────────

func play_dialogue(lines: Array) -> void:
	_lines = lines
	_current_index = 0
	panel.visible = true
	get_tree().paused = true
	_show_line(_current_index)


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
# ────────────────────────────────────────────

func play_intro() -> void:
	play_dialogue([
		line("Dragon", "Why hello, brave Knight! Have you come to rescue the princess?"),
		line("Dragon", "I hear the King is offering her hand to anyone who can save her!"),
		line("Dragon", "Ha! Any fool can save the princess!"),
		line("Dragon", "Now, I've talked to the princess and we've devised... a plan."),
		line("Dragon", "If you don't win her heart by the time you get up there, I'll eat you!"),
		line("Dragon", "I'll tell her you're on your way!"),
	])


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


func play_win() -> void:
	play_dialogue([
		line("Princess", "Oh my... you actually remembered everything I like."),
		line("Princess", "I... I think I might be falling for you."),
		line("Knight", "Then let's go. Together."),
		line("Dragon", "...I'm not crying. There's smoke in my eyes."),
		line("Dragon", "Go on then. You've earned it."),
	])


func play_retry_ending() -> void:
	play_dialogue([
		line("Princess", "Hmm. You tried. Sort of."),
		line("Princess", "I'm not impressed enough to marry you, but... you're not terrible."),
		line("Princess", "Come back when you actually know me."),
		line("Knight", "I — wait —"),
		line("Dragon", "She pushed him off. Classic. I'll go retrieve him."),
	])


func play_game_over() -> void:
	play_dialogue([
		line("Princess", "...You brought me nothing? Nothing at all?"),
		line("Princess", "I'm going back inside."),
		line("Dragon", "Well. A deal's a deal."),
		line("Dragon", "Don't worry. I'm sure you were very brave."),
		line("Dragon", "Mostly."),
	])
