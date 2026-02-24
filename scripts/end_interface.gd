extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Knight":
		GameState.stop_timer()
		$CanvasLayer/End_Screen.on_game_end()
