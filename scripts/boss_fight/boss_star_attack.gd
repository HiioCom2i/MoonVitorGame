class_name BossStarAttack
extends GOAPAction

var spawn_area: Node  # Referência ao nodo de spawn
var damage: float  # Dano causado pelo ataque de estrelas
var boss: CharacterBody2D

func _init(spawn_node: Node, damage: float, boss: CharacterBody2D):
	self.spawn_area = spawn_node
	self.damage = damage  # Inicializa o dano
	self.boss = boss
	# Define as pré-condições e efeitos específicos da ação
	preconditions = {
	"mana": {"operator": ">=", "value": 60},
	#"attack_timer_ready": true
}

	effects = {
		"attack": true,  # O jogador será danificado
		#"attack_timer_ready": false  # Timer será reiniciado após o ataque
	}

	cost = -damage  # O custo é o dano em negativo para priorizar ataques mais poderosos
# Método para executar a ação
func execute() -> bool:
	if is_running:
		return false
		
	boss.mana -= 60
	if spawn_area:
		# Executa a lógica de spawn
		spawn_area.spawn_star_areas()
		print("BossStarAttack em execução!")
		is_running = true

		# Finaliza a ação diretamente, sem chamar apply
		finalize()
		return true
	else:
		print("Erro: Nodo de spawn não encontrado!")
		return false

# Método para aplicar os efeitos da ação
func apply(state: Dictionary) -> Dictionary:
	if spawn_area:
		print("Apply do BossStarAttack!")
		# Atualiza o estado com os efeitos definidos
		var new_state = state.duplicate()  # Cria uma cópia do estado original
		new_state["attack"] = true
		  # Define que o ataque foi realizado
		# new_state["attack_timer_ready"] = false  # Opcional: Atualiza o estado do timer se necessário

		return new_state
	else:
		print("Erro: Nodo de spawn não encontrado durante apply!")

	return state



# Método para finalizar a ação
func finalize() -> void:
	if is_running:
		is_running = false
		print("BossStarAttack finalizada.")
