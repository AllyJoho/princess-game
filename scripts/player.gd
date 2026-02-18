extends CharacterBody2D

@export var speed = 300
@export var gravity = 30
@export var jump_force = 300

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 500:
			velocity.y = 500
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force
	
	var horizonal_direction = Input.get_axis("move_left","move_right" )
	velocity.x = speed  * horizonal_direction
	move_and_slide()
	pass
