extends Node2D

@onready var player = $player
var jump_pad_preload = preload("res://player/jump_pad/jump_pad.tscn")
@onready var background = $player/background

func _ready() -> void:
	player.connect("double_jump_signal", _double_jump)
	print(background.scale.x)
	background.scale.x += int(max(DisplayServer.screen_get_size().x / 1920, DisplayServer.screen_get_size().y / 1080)) - 1
	background.scale.y += int(max(DisplayServer.screen_get_size().x / 1920, DisplayServer.screen_get_size().y / 1080)) - 1
	print(background.scale.x)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quitte"):
		quitte()
	
	if player.global_position.y >= 1000:
		tp()
	
	


func _double_jump():
	var jump_pad = jump_pad_preload.instantiate()
	add_child(jump_pad)
	jump_pad.global_position.x = player.global_position.x
	jump_pad.global_position.y = player.global_position.y + 48.0

func quitte():
	get_tree().quit()

func tp():
	player.global_position = player.tp_location
	player.reset()
