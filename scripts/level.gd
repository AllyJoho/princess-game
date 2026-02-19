extends Node2D

# Housekeeping
var platform = preload("res://scenes/platform.tscn")
var rng = RandomNumberGenerator.new( )
var grass_texture = preload("res://assets/sprites/tiles/grass_dirt.png")
var stone_texture = preload("res://assets/sprites/tiles/stone_block.png")
var wall_texture = preload("res://assets/sprites/tiles/stone_wall.png")
var gift_place = preload("res://assets/sprites/tiles/dirt_block.png")

# Important Numbers
var level_width = 10
var level_height = 10
var block_length = 64

func _ready():
	generate_tower()

func spawn_object(x,y,object,texture=null):
	var p = object.instantiate()
	p.position = Vector2(x,y)
	if(texture != null):
		p.get_node("Sprite2D").texture = texture
	add_child(p)

func generate_tower():
	var wallPos = (level_width/2)*block_length
	var y_pos = 0
	for i in range(level_height):
		if i == 0:
			for j in range(level_width+1):
				spawn_object((-wallPos+j*block_length),y_pos, platform, grass_texture)
		y_pos -= block_length
		spawn_object(-wallPos,y_pos, platform, wall_texture)
		spawn_object(wallPos,y_pos, platform, wall_texture)
