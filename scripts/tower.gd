extends Node2D
var rng: RandomNumberGenerator

# Objects
var block = preload("res://scenes/block.tscn")
var platform = preload("res://scenes/platform.tscn")
#Textures
var grass_texture = preload("res://assets/sprites/tiles/grass_dirt.png")
var dirt_texture = preload("res://assets/sprites/tiles/dirt_block.png")
var wall_texture = preload("res://assets/sprites/tiles/stone_wall.png")
var platform_texture = preload("res://assets/sprites/tiles/path_stone_slab.png")
var gift_platform_texture = preload("res://assets/sprites/tiles/snow_stone_slab.png")

# Important Numbers
@export var level_width = 14
@export var floors = 25
@export var block_size = 64.0
@export var platform_chance = 0.2
var wall_pos = (level_width*block_size)/2
var total_platforms = floors

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

func build_platform(y_pos, is_gift):
	var x_pos = randf_range(-wall_pos+block_size, wall_pos-block_size)
	if is_gift != -1:
		spawn_object(x_pos,y_pos, platform, gift_platform_texture)
	else:
		spawn_object(x_pos,y_pos, platform, platform_texture)

func build_walls():
	var y_pos = block_size
	for j in range(-5,level_width+6):
		spawn_object((-wall_pos+j*block_size),y_pos, block, grass_texture)
		spawn_object((-wall_pos+j*block_size),y_pos+block_size, block, dirt_texture)
	for i in range(floors+4):
		y_pos -= block_size
		spawn_object(-wall_pos,y_pos, block, wall_texture)
		spawn_object(wall_pos,y_pos, block, wall_texture)
	for j in range(1,level_width-1):
		spawn_object((-wall_pos+j*block_size),y_pos, platform, platform_texture)

func build_tower():
	var y_pos = -block_size*2
	var gift_platforms = get_unique_random_numbers(0,total_platforms-1,5)
	for i in range(total_platforms):
		build_platform(y_pos-i*block_size, gift_platforms.find(i))

func _ready():
	rng = RandomNumberGenerator.new()
	build_walls()
	build_tower()
