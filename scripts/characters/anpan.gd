class_name Anpan
extends Character

const SPECIAL_MOVE_X := 10

func _init() -> void:
	super._init(Vector2(100, 150))
	
func unique_process(attack: Attack) -> void:
	if state == State.SPECIAL:
		if attack.is_active_frame():
			position.x += SPECIAL_MOVE_X * direction
		velocity = Vector2.ZERO
	
class AnpanModel extends Model:
	pass
