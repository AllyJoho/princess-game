extends CharacterBody2D

@export var speed = 700
@export var gravity = 30
@export var jump_force = 900
@export var max_fall = 2000

func _physics_process(delta: float) -> void:
	print(position)
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > max_fall:
			velocity.y = max_fall
	
	if Input.is_action_just_pressed("jump"):# &&  is_on_floor():
		velocity.y = -jump_force
	 
	var horizonal_direction = Input.get_axis("move_left","move_right" )
	velocity.x = speed  * horizonal_direction
	move_and_slide()
	pass
