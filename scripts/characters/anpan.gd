class_name Anpan
extends Character

func _init(characters: Array[Character]) -> void:
	super._init(characters, Vector2(100, 150))
	
func special_process(progress: float) -> void:
	if progress == 0:
		model.attack(false)
		enable_physics = false
		attack_areas.append(AttackArea.new(self, size / 2, attack_damages[3].duplicate()))
		add_child(attack_areas[-1])
		attack_areas[-1].position.x = size.x * 0.75 * direction
	elif 0.333 < progress and progress < 1.0:
		model.attack(true)
		attack_areas[-1].process()
	elif progress == 1.0:
		var attack_area = attack_areas.pop_back()
		attack_area.queue_free()
	
	enable_physics = false
	position.x += direction * walk_step * 1.5

class AnpanModel extends Model:
	pass
