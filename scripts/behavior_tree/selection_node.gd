extends BehaviorNode
class_name SelectorNode

var children: Array = []

# Construtor que recebe os nós filhos
func _init(child_nodes: Array):
	children = child_nodes

# Função tick, que é chamada a cada frame
func tick(agent) -> int:
	# Itera sobre os filhos do nó de seleção
	for child in children:
		var status = child.tick(agent)  # Executa o nó filho

		# Se algum dos filhos retornar SUCCESS, o nó de seleção retorna SUCCESS
		if status == Status.SUCCESS:
			return Status.SUCCESS
		# Se algum dos filhos retornar RUNNING, o nó de seleção também retorna RUNNING
		elif status == Status.RUNNING:
			return Status.RUNNING
	
	# Se todos os filhos falharem, retorna FAILURE
	return Status.FAILURE
