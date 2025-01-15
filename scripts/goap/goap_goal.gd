class_name Goal
extends Resource

# Propriedades do objetivo
var priority: int = 1       # Prioridade do objetivo
var conditions: Dictionary  # Estado desejado do mundo

func _init(priority: int, conditions: Dictionary):
	self.priority = priority
	self.conditions = conditions

# Avalia a utilidade do objetivo com base no estado do mundo
func evaluate(world_state: Dictionary) -> int:
	return priority
