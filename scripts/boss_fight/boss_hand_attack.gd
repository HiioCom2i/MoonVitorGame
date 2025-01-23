class_name BossHandAttack
extends GOAPAction

var hand_left: CharacterBody2D
var hand_right: CharacterBody2D
var boss: CharacterBody2D
var damage: float  # Defina o dano aqui

func _init(hand_left: CharacterBody2D, hand_right: CharacterBody2D, boss: CharacterBody2D, damage: float):
	self.hand_left = hand_left  # Configura a mão esquerda
	self.hand_right = hand_right  # Configura a mão direita
	self.boss = boss  # Configura o boss
	self.damage = damage  # Inicialize o dano

	# Define as pré-condições e efeitos específicos da ação
	preconditions = {
		"mana": {"operator": "<=", "value": 60},
	}
	effects = {
		"mana_restored": true,  # O efeito desejado é restaurar a mana
		#"attack_timer_ready": false,  # Timer será reiniciado após o ataque
		"attack": true
	}

	cost = -damage  # O custo é o dano em negativo para priorizar ataques mais poderosos

# Método para aplicar os efeitos da ação
# Método para aplicar os efeitos da ação
func apply(state: Dictionary) -> Dictionary:
	if hand_left and hand_right:
		print("Apply do BossHandAttack!")

		# Movimenta as mãos para simular o ataque
		# hand_left.attack()  # Mover a mão esquerda
		# hand_right.attack()  # Mover a mão direita

		# Lógica para restaurar mana
		boss.mana += 20
		if boss.mana > boss.max_mana:
			boss.mana = boss.max_mana

		# Atualiza o estado com os efeitos definidos
		var new_state = state.duplicate()  # Cria uma cópia do estado para evitar mutações diretas
		new_state["mana"] = boss.mana
		new_state["attack"] = true  # Define que o ataque foi realizado
		# new_state["attack_timer_ready"] = false  # Opcional: Atualiza o estado do timer se necessário

		return new_state
	else:
		print("Erro: Mãos não configuradas!")

	return state


# Método para executar a ação
func execute() -> bool:
	if is_running:
		return false
	print("executou o BossHandAttack")
	# Marca como em execução
	is_running = true

	# Simula o ataque real (sem alterar o estado diretamente aqui)
	#if hand_left and hand_right:
		#print("Executando ataque das mãos!")
		#hand_left.attack()
		#hand_right.attack()

	finalize()  # Finaliza a ação
	return true

func finalize():
	is_running = false
	print("Finalizando BossHandAttack!")
	
	# Redefine o estado "attack" para permitir novos ataques
	boss.global_state["attack"] = false
