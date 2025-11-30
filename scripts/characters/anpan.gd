class_name Anpan
extends Character

func _init(characters: Array[Character]) -> void:
	one_attack_duration *= 1
	super._init(characters, Vector2(100, 150))
	
func special_process(progress: float) -> void:
	if progress == 0:
		model.attack(false)
		enable_physics = false
		attack_areas.append(AttackArea.new(self, size / 2, attack_damages[3].duplicate()))
		add_child(attack_areas[-1])
		attack_areas[-1].position.x = size.x * 0.75 * direction
	elif 0.333 < progress and progress < 1.0:
		attack_areas[-1].process()
	elif progress == 1.0:
		var attack_area = attack_areas.pop_back()
		attack_area.queue_free()
	
	if progress_equal(progress, 0.333):
		print("Special attack progress reached 0.333")
		model.attack(true)
	else:
		print("Special attack progress: ", progress)
	enable_physics = false
	position.x += direction * 10

class AnpanModel extends Model:
	func attack(finish: bool) -> void:
		punch(finish)