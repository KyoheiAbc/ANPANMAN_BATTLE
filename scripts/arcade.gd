class_name Arcade
extends Node

var sprites: Array[Sprite2D]

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	self.queue_free()
	Main.NODE.add_child(Game.new())
