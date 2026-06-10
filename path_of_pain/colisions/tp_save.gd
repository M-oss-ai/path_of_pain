extends Area2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.tp_location = global_position
		body.tp_location.y -= 16
