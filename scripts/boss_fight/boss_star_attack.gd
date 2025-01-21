class_name BossStarAttack
extends GOAPAction

var spawn_area: Node  # Referência ao nodo de spawn

func _init(spawn_node: Node):
	cost = 5
	preconditions = {"player_in_arena": true}  # Atualize conforme necessário
	effects = {"player_damaged": true}  # Atualize conforme necessário
	spawn_area = spawn_node

# Método para executar a ação
func execute() -> bool:
	if is_running:
		return false

	if spawn_area:
		spawn_area.spawn_star_areas()
		print("BossStarAttack em execução!")
		is_running = true
		finalize() # Finaliza a ação logo após ser concluída
		return true
	else:
		print("Erro: Nodo de spawn não encontrado!")
		return false


# Método para finalizar a ação
func finalize() -> void:
	if is_running:
		is_running = false
		print("BossStarAttack finalizada.")
