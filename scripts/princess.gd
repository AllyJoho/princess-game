extends Area2D

# ──────────────────────────────────────────────
#  princess.gd
#  Attach to the Princess node at the top of the tower.
#  Node structure expected:
#
#  Princess (Area2D)
#  ├── CollisionShape2D   (trigger zone)
#  └── AnimatedSprite2D   (princess sprite)
#
#  This node needs access to the Cutscene and ItemMenu
#  autoloads / nodes. Adjust the paths below if needed.
# ──────────────────────────────────────────────

## Path to the Cutscene CanvasLayer node in the scene tree.
## Adjust if your scene structure is different.
@export var cutscene_path: NodePath = "/root/Tower/Cutscene"
@export var item_menu_path: NodePath = "/root/Tower/ItemMenu"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _triggered: bool = false
var _cutscene: Node
var _item_menu: Node


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_cutscene  = get_node(cutscene_path)
	_item_menu = get_node(item_menu_path)


func _on_body_entered(body: Node) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return

	_triggered = true
	_evaluate()


func _evaluate() -> void:
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
	animated_sprite.play("love")   # Play a happy animation if available
	_cutscene.play_win()
	await _cutscene.dialogue_finished
	# TODO: transition to a win screen or end scene
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")


func _do_retry() -> void:
	animated_sprite.play("push")   # Play a push-off animation if available
	_cutscene.play_retry_ending()
	await _cutscene.dialogue_finished

	# Get one vague hint for next attempt
	var hint: String = GameState.get_hint_for_attempt()
	GameState.reset_attempt()

	# Play dragon hint dialogue, then reload the tower
	_cutscene.play_retry_hints(hint, GameState.attempt_number)
	await _cutscene.dialogue_finished

	# Reload the main game scene (tower regenerates, preferences persist)
	get_tree().reload_current_scene()


func _do_game_over() -> void:
	_cutscene.play_game_over()
	await _cutscene.dialogue_finished
	GameState.new_game()   # Reset everything including preferences
	# TODO: transition to game over screen
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
