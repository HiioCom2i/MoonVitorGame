class_name GOAPAction
extends Resource

# Propriedades da ação
var cost: int = 1          # Custo da ação
var preconditions: Dictionary = {}  # Condições necessárias para executar
var effects: Dictionary = {}        # Efeitos da ação
var is_running: bool = false        # Se a ação está em execução

# Verifica se a ação pode ser executada no estado atual
func can_execute(world_state: Dictionary) -> bool:
	for key in preconditions.keys():
		if world_state.get(key) != preconditions[key]:
			return false
	return true

# Executa a ação
func execute() -> bool:
	# Sobrescreva para implementar a lógica da ação
	return true

# Finaliza a ação
func finalize() -> void:
	is_running = false
