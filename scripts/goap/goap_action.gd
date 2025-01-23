class_name GOAPAction
extends Resource

# Propriedades da ação
var cost: float          # Custo da ação
var preconditions: Dictionary = {}  # Condições necessárias para executar
var effects: Dictionary = {}        # Efeitos da ação
var is_running: bool = false        # Se a ação está em execução

# Verifica se a ação pode ser executada no estado atual
func can_execute(world_state: Dictionary) -> bool:
	for key in preconditions.keys():
		var condition = preconditions[key]
		
		# Se a condição for uma comparação (como ">=", "<=", etc.)
		if typeof(condition) == TYPE_DICTIONARY:
			if condition.has("operator") and condition.has("value"):
				var operator = condition["operator"]
				var value = condition["value"]

				if operator == ">=" and world_state.get(key, 0) < value:
					return false
				elif operator == "<=" and world_state.get(key, 0) > value:
					return false
				elif operator == ">" and world_state.get(key, 0) <= value:
					return false
				elif operator == "<" and world_state.get(key, 0) >= value:
					return false
				elif operator == "==" and world_state.get(key, 0) != value:
					return false
				elif operator == "!=" and world_state.get(key, 0) == value:
					return false
		else:
			# Condição padrão (igualdade)
			if world_state.get(key) != condition:
				return false
	return true


# Executa a ação
func execute() -> bool:
	# Sobrescreva para implementar a lógica da ação
	return true

# Finaliza a ação
func finalize() -> void:
	is_running = false
