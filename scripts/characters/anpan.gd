class_name Anpan
extends Character

func _init() -> void:
	super._init(Vector2(100, 150))
	
func unique_process(attack: Attack) -> void:
	if state != State.SPECIAL:
		return
	if attack.frame_count > attack.info.counts[2] + attack.info.counts[1]:
		velocity = Vector2.ZERO
	elif attack.frame_count > attack.info.counts[2]:
		position.x += 12 * direction
		velocity = Vector2.ZERO
	else:
		pass

class AnpanModel extends Model:
	pass
