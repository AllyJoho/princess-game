extends Node2D
# balcony_princess.gd
# Attach to a Node2D in tower.tscn that sits at the top of the tower (balcony position).
# The princess starts off-screen to the right and runs in when triggered.

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	add_to_group("balcony_princess")


func run_in() -> void:
	anim_player.play("run_in")
	sprite.play("princess")


func run_out() -> void:
	anim_player.play("run_out")
	sprite.play("princess")
