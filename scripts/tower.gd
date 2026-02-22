extends Node2D
var rng: RandomNumberGenerator

# Objects
var block = preload("res://scenes/platform.tscn")
var platform = preload("res://scenes/half_platform.tscn")
#Textures
var grass_texture = preload("res://assets/sprites/tiles/grass_dirt.png")
var wall_texture = preload("res://assets/sprites/tiles/stone_wall.png")
var platform_texture = preload("res://assets/sprites/tiles/dirt_block.png")
var gift_platform_texture = preload("res://assets/sprites/tiles/dirt_block.png")

# Important Numbers
@export var level_width = 14
@export var floors = 10
@export var block_size = 64
@export var platform_chance = 0.2
var wall_pos = (level_width/2)*block_size
var total_platforms = floors*5

func spawn_object(x,y,object,texture=null):
	var p = object.instantiate()
	p.position = Vector2(x,y)
	if(texture != null):
		p.get_node("Sprite2D").texture = texture
	add_child(p)

func get_unique_random_numbers(min_val: int, max_val: int, count: int) -> Array:
	var possible_numbers = []
	for i in range(min_val, max_val + 1):
		possible_numbers.append(i)
	possible_numbers.shuffle()
	return possible_numbers.slice(0, count)

func build_floors(y_pos, index_array):
#	for each of the slots

	pass

func build_walls():
	pass

func build_tower():
	var y_pos = block_size
	var gift_legs = get_unique_random_numbers(1,total_platforms,5)


func _ready():
	rng = RandomNumberGenerator.new()
	build_tower()
