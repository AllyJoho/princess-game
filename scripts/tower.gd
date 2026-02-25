extends Node2D

# ──────────────────────────────────────────────
#  tower.gd  (fixed)
#  Changes:
#   - gift_obj.item_touched signal connection removed (gift.gd handles itself)
#   - Intro cutscene now fires on attempt 1
#   - gift.tscn used (sister's system)
# ──────────────────────────────────────────────

var rng: RandomNumberGenerator

# Objects
var block    = preload("res://scenes/block.tscn")
var platform = preload("res://scenes/platform.tscn")
var gift     = preload("res://scenes/gift.tscn")

# Textures
var grass_texture         = preload("res://assets/tiles/grass.png")
var dirt_texture          = preload("res://assets/tiles/dirt.png")
var wall_texture          = preload("res://assets/tiles/wall.png")
var platform_texture      = preload("res://assets/tiles/platform.png")
var gift_platform_texture = preload("res://assets/tiles/gift_platform.png")

# Important Numbers
@export var level_width    = 14
@export var floors         = 25
@export var block_size     = 64.0
@export var platform_size  = 112.0
@export var platform_chance = 0.2
var wall_pos        = 0.0
var total_platforms = 0

# Node references
@onready var cutscene: CanvasLayer = $Cutscene


func _ready() -> void:
	rng = RandomNumberGenerator.new()
	wall_pos        = (level_width * block_size) / 2
	total_platforms = floors

	GameState.start_timer()
	build_walls()
	build_tower()

	# Play intro once per game, retry hints on all subsequent attempts
	if not GameState.intro_played:
		GameState.intro_played = true
		cutscene.play_intro()
	else:
		var hint = GameState.get_hint_for_attempt()
		cutscene.play_retry_hints(hint, GameState.attempt_number)


func spawn_object(x, y, object, texture = null):
	var p = object.instantiate()
	p.position = Vector2(x, y)
	if texture != null:
		p.get_node("Sprite2D").texture = texture
	add_child(p)
	return p


func get_unique_random_numbers(min_val: int, max_val: int, count: int) -> Array:
	var possible_numbers = []
	for i in range(min_val, max_val + 1):
		possible_numbers.append(i)
	possible_numbers.shuffle()
	return possible_numbers.slice(0, count)


func build_platform(y_pos, gift_category: String) -> void:
	var x_pos = randf_range(-wall_pos + platform_size, wall_pos - platform_size)
	var tex   = gift_platform_texture if gift_category != "" else platform_texture
	spawn_object(x_pos, y_pos, platform, tex)

	if gift_category != "":
		var gift_obj = gift.instantiate()
		gift_obj.position = Vector2(x_pos, y_pos - block_size)
		gift_obj.index = GameState.ITEM_NAMES.find(gift_category)
		add_child(gift_obj)


func build_walls() -> void:
	var y_pos = block_size
	for j in range(-6, level_width + 7):
		spawn_object((-wall_pos + j * block_size), y_pos, block, grass_texture)
		spawn_object((-wall_pos + j * block_size), y_pos + block_size, block, dirt_texture)
	for i in range(floors + 4):
		y_pos -= block_size
		spawn_object(-wall_pos - 5 * block_size, y_pos, block)
		for j in range(7):
			spawn_object(wall_pos + j * block_size, y_pos, block, wall_texture)
	for j in range(level_width - 10, level_width):
		spawn_object((-wall_pos + j * platform_size), y_pos, platform, platform_texture)


func build_tower() -> void:
	var y_pos = -block_size * 2
	var gift_indices = get_unique_random_numbers(0, total_platforms - 1, 5)
	var categories   = GameState.ITEM_NAMES.duplicate()
	categories.shuffle()

	for i in range(total_platforms):
		var cat_index = gift_indices.find(i)
		var category  = categories[cat_index] if cat_index != -1 else ""
		build_platform(y_pos - i * block_size, category)
