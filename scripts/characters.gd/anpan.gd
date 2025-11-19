class_name Anpan
extends Character

func _init():
	super._init(Vector2(100, 150))
	model = AnpanModel.new(self)
	add_child(model)

	
class AnpanModel extends Model:
	func _init(character: Character) -> void:
		root = load("res://assets/a.gltf").instantiate()
		super._init(character)
