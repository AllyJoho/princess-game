extends Node2D

# Housekeeping
var platform = preload("res://scenes/platform.tscn")
var half_platform = preload("res://scenes/half_platform.tscn")
var rng: RandomNumberGenerator
var grass_texture = preload("res://assets/sprites/tiles/grass_dirt.png")
var stone_texture = preload("res://assets/sprites/tiles/stone_block.png")
var wall_texture = preload("res://assets/sprites/tiles/stone_wall.png")
var gift_place = preload("res://assets/sprites/tiles/dirt_block.png")

# Important Numbers
var level_width = 14
var level_height = 30
var block_length = 64
var half_platform_chance = 0.2

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

func build_leg(side, y_pos, wall_pos, is_gift):
	var x_pos = side*(wall_pos-block_length)
	if is_gift:
		spawn_object(x_pos,y_pos, platform, gift_place)
	else:
		spawn_object(x_pos,y_pos, platform, stone_texture)
	var leg_len = randi_range(0,2)
	for i in range(leg_len):
		x_pos -= side*block_length
		spawn_object(x_pos,y_pos, platform, stone_texture)

func build_half_platforms(y_pos, wall_pos):
	var chance = [half_platform_chance, half_platform_chance, 1]
	chance.shuffle()
	for i in range(3):
		var x_pos = -wall_pos+(5 + 2*i)*block_length + randf_range(-1,1)*(block_length/2)
		if randf() < chance[i]:
			spawn_object(x_pos,y_pos, half_platform)
	pass

func generate_tower():
	var wall_pos = (level_width/2)*block_length
	var y_pos = block_length
	var gift_legs = get_unique_random_numbers(1,18,5)
	var leg = 1
	for i in range(level_height):
		if i == 0:
			for j in range(level_width+1):
				spawn_object((-wall_pos+j*block_length),y_pos, platform, grass_texture)
		if i > 0 && i%3==0:
			build_leg(-1,y_pos,wall_pos,(leg in gift_legs))
			leg += 1
			build_leg(1,y_pos,wall_pos,(leg in gift_legs))
			leg += 1
		if i%3==2:
			build_half_platforms(y_pos,wall_pos)
		y_pos -= block_length
		spawn_object(-wall_pos,y_pos, platform, wall_texture)
		spawn_object(wall_pos,y_pos, platform, wall_texture)

func _ready():
	rng = RandomNumberGenerator.new()
	generate_tower()
