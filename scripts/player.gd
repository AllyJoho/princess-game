extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 700
@export var gravity = 30
@export var jump_force = 900
@export var max_fall = 2000

func _ready():
	animated_sprite_2d.stop()
	animated_sprite_2d.play("idle")

func _physics_process(_delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > max_fall:
			velocity.y = max_fall
	
	if Input.is_action_just_pressed("jump") &&  is_on_floor():
		velocity.y = -jump_force
	 
	var horizonal_direction = Input.get_axis("move_left","move_right" )
	velocity.x = speed  * horizonal_direction
	move_and_slide()
	if velocity.y < 0:
		animated_sprite_2d.play("fall")
		animated_sprite_2d.flip_h = true
	elif velocity.y > 0:
		animated_sprite_2d.play("jump")
		animated_sprite_2d.flip_h = false
	elif horizonal_direction < 0:
		animated_sprite_2d.play("walk")
		animated_sprite_2d.flip_h = true
	elif horizonal_direction > 0:
		animated_sprite_2d.play("walk")
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.play("idle")
	
