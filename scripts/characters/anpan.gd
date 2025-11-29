class_name Anpan
extends Character

func _init():
	super._init(Vector2(100, 150))

func damage(damage: Damage) -> void:
	if state == State.SPECIAL:
		return
	super.damage(damage)
		
class AnpanModel extends Model:
	pass
