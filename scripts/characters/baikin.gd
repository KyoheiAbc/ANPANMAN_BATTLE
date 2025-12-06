class_name Baikin
extends Character

func _init() -> void:
	attack_infos[3] = Attack.Info.new([10, 5, 30], Vector2(50, 0), Vector2(100, 100), 30, Vector2(16, -32), 60, 30)
	super._init(Vector2(100, 150))

func unique_process(attack: Attack) -> void:
	if state == State.SPECIAL:
		if attack.frame_count == attack.total_frame_count() - attack.info.counts[0]:
			velocity = Vector2(2 * direction, -16)

class BaikinModel extends Model:
	pass