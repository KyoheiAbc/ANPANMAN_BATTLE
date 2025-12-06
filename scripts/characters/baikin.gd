class_name Baikin
extends Character

const ATTACK_INFO_COUNTS := [10, 5, 30]
const ATTACK_INFO_OFFSET := Vector2(50, 0)
const ATTACK_INFO_SIZE := Vector2(100, 100)
const ATTACK_INFO_DAMAGE := 30
const ATTACK_INFO_KNOCKBACK := Vector2(16, -32)
const ATTACK_INFO_COOL := 60
const ATTACK_INFO_SPECIAL := 30
const SPECIAL_VELOCITY_X := 2
const SPECIAL_VELOCITY_Y := -16

func _init() -> void:
	attack_infos[3] = Attack.Info.new(
		ATTACK_INFO_COUNTS,
		ATTACK_INFO_OFFSET,
		ATTACK_INFO_SIZE,
		ATTACK_INFO_DAMAGE,
		ATTACK_INFO_KNOCKBACK,
		ATTACK_INFO_COOL,
		ATTACK_INFO_SPECIAL
	)
	super._init(Vector2(100, 150))

func unique_process(attack: Attack) -> void:
	if state == State.SPECIAL:
		if attack.frame_count == attack.total_frame_count() - attack.info.counts[0]:
			velocity = Vector2(SPECIAL_VELOCITY_X * direction, SPECIAL_VELOCITY_Y)

class BaikinModel extends Model:
	pass