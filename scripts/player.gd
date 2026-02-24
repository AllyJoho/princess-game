extends CharacterBody2D

# ──────────────────────────────────────────────
#  player.gd  (updated)
#  Changes from original:
#   - Player is added to the "player" group so
#     item.gd and princess.gd can identify it
#   - Sprite flip added for left/right movement
# ──────────────────────────────────────────────

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var speed      = 500
@export var gravity    = 30
@export var jump_force = 900
@export var max_fall   = 2000


func _ready() -> void:
	add_to_group("player")   # Required for item and princess detection
	animated_sprite_2d.stop()
	animated_sprite_2d.play("idle")


func _physics_process(_delta: float) -> void:
	# Gravity
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > max_fall:
			velocity.y = max_fall

	# Jump
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = -jump_force

	# Horizontal movement
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * horizontal_direction
	move_and_slide()

	# Sprite flipping
	if horizontal_direction > 0:
		animated_sprite_2d.flip_h = false
	elif horizontal_direction < 0:
		animated_sprite_2d.flip_h = true

	# Animation priority: fall > jump > walk > idle
	if velocity.y > 0:
		animated_sprite_2d.play("fall")
	elif velocity.y < 0:
		animated_sprite_2d.play("jump")
	elif horizontal_direction != 0:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")
