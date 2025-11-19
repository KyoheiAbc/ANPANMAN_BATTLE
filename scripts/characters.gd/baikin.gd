class_name Baikin
extends Character

func _init():
	super._init(Vector2(100, 150))
	model = BaikinModel.new(self)
	add_child(model)


class BaikinModel extends Model:
	func _init(character: Character) -> void:
		root = load("res://assets/b.gltf").instantiate()
		super._init(character)