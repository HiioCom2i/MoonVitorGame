class_name AStarGOAP

# Representa o algoritmo A* para o GOAP
func find_best_plan(actions: Array, initial_state: Dictionary, goal_state: Dictionary) -> Array:
	# Nós abertos e fechados
	var open_list = []
	var closed_list = []

	# Adiciona o estado inicial à lista aberta
	open_list.append({
		"state": initial_state,
		"path": [],
		"g": 0,
		"h": heuristic(initial_state, goal_state),
		"f": 0  # Será calculado como g + h
	})

	while open_list.size() > 0:
		# Ordena os nós pelo menor f (g + h)
		open_list.sort_custom(_compare_by_f)
		var current_node = open_list.pop_front()

		# Verifica se o estado atual atende ao objetivo
		if is_goal_reached(current_node["state"], goal_state):
			return current_node["path"]

		closed_list.append(current_node)

		# Expande os estados vizinhos com base nas ações disponíveis
		for action in actions:
			if action.can_execute(current_node["state"]):
				var new_state = action.apply(current_node["state"])
				var new_g = current_node["g"] + calculate_cost(action)
				var new_node = {
					"state": new_state,
					"path": current_node["path"] + [action],
					"g": new_g,
					"h": heuristic(new_state, goal_state),
					"f": new_g + heuristic(new_state, goal_state)
				}
				
				# Ignorar estados já processados
				if not _is_in_list(closed_list, new_state):
					open_list.append(new_node)

	# Se não encontrar um plano, retorna vazio
	return []

# Calcula a heurística (pode ser zero, ou uma estimativa futura)
func heuristic(state: Dictionary, goal: Dictionary) -> float:
	# Simplesmente retornar zero para o caso atual
	return 0

# Verifica se o estado atual atende ao objetivo
func is_goal_reached(state: Dictionary, goal: Dictionary) -> bool:
	for key in goal.keys():
		if state.get(key, null) != goal[key]:
			return false
	return true

# Calcula o custo (inverso do dano causado, pois queremos maximizar o dano)
func calculate_cost(action) -> float:
	return -action.damage  # Dano negativo para maximizar

# Verifica se um estado já está na lista
func _is_in_list(node_list: Array, state: Dictionary) -> bool:
	for node in node_list:
		if node["state"] == state:
			return true
	return false

# Ordenação pelo menor F (custo total estimado)
func _compare_by_f(a, b) -> int:
	return a["f"] - b["f"]
