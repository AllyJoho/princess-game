extends Area2D

# ──────────────────────────────────────────────
#  princess.gd  (fixed)
#  Changes:
#   - Uses GameState.prepare_hint_for_retry() before reload
#     so tower.gd can read it cleanly without a second hint call
#   - "push" animation falls back to "idle" if unavailable
# ──────────────────────────────────────────────

@export var cutscene_path: NodePath = "/root/Tower/Cutscene"

# Null guard — won't crash if AnimatedSprite2D hasn't been added in the editor yet
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

var _triggered: bool = false
var _cutscene: Node


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_cutscene = get_node(cutscene_path)


func _on_body_entered(body: Node) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return
	_triggered = true
	_evaluate()


## Safe animation helper — no-ops if the sprite or animation doesn't exist yet
func _play_anim(anim_name: String) -> void:
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)


func _evaluate() -> void:
	GameState.stop_timer()
	var outcome = GameState.evaluate_outcome()
	match outcome:
		GameState.Outcome.WIN:
			_do_win()
		GameState.Outcome.RETRY:
			_do_retry()
		GameState.Outcome.GAME_OVER:
			_do_game_over()


# ────────────────────────────────────────────
#  Outcomes
# ────────────────────────────────────────────

func _do_win() -> void:
	var balcony = get_tree().get_first_node_in_group("balcony_princess")
	if balcony:
		balcony.run_in()
	await get_tree().create_timer(0.8).timeout
	_play_anim("love")
	_cutscene.play_win()
	await _cutscene.dialogue_finished
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")


func _do_retry() -> void:
	var balcony = get_tree().get_first_node_in_group("balcony_princess")
	if balcony:
		balcony.run_in()
	await get_tree().create_timer(0.8).timeout
	_play_anim("idle")  # swap "idle" for "push" once that animation exists in the sprite sheet
	var extra = GameState.generate_retry_dialogue()
	_cutscene.play_retry_ending(extra)
	await _cutscene.dialogue_finished

	# Prepare hint and reset BEFORE reload so tower.gd picks it up
	GameState.prepare_hint_for_retry()
	GameState.reset_attempt()

	get_tree().reload_current_scene()


func _do_game_over() -> void:
	var balcony = get_tree().get_first_node_in_group("balcony_princess")
	if balcony:
		balcony.run_in()
	await get_tree().create_timer(0.8).timeout
	_cutscene.play_game_over()
	await _cutscene.dialogue_finished
	GameState.new_game()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
