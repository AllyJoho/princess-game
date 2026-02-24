extends Area2D

var index: int = 0



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Knight":
		print("Got gift ",index)
		self.queue_free()
