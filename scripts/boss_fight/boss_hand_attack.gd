class_name BossHandAttack
extends GOAPAction

var hand_left: CharacterBody2D
var hand_right: CharacterBody2D
var boss: CharacterBody2D
var damage: float  # Defina o dano aqui

func _init(hand_left: CharacterBody2D, hand_right: CharacterBody2D, boss: CharacterBody2D, damage: float):
	self.damage = damage  # Inicialize o dano
	cost = 20  # Custo alto já que é menos eficiente que o ataque de estrelas
	preconditions = {"mana": 0}  # O ataque só ocorre quando a mana for 0
	effects = {"mana_restored": true}  # O efeito desejado é restaurar a mana

	self.hand_left = hand_left  # Configura a mão esquerda
	self.hand_right = hand_right  # Configura a mão direita
	self.boss = boss  # Configura o boss

# Método para aplicar os efeitos da ação
func apply(state: Dictionary) -> Dictionary:
	# Aplica a lógica do ataque das mãos
	if hand_left and hand_right:
		print("Ataque das mãos iniciado!")

		# Movimenta as mãos para simular o ataque
		hand_left.position += Vector2(-10, 0)  # Mover a mão esquerda
		hand_right.position += Vector2(10, 0)  # Mover a mão direita

		# Lógica para restaurar mana
		boss.mana += 20  # Supondo que o boss tenha uma variável de mana
		if boss.mana > boss.max_mana:
			boss.mana = boss.max_mana

		# Atualiza o estado
		state["mana"] = boss.mana  # Atualiza o estado da mana
	else:
		print("Erro: Mãos não configuradas!")

	return state

# Método para executar a ação
func execute() -> bool:
	if is_running:
		return false

	# Chama a função apply dentro do execute para aplicar o efeito no estado
	var current_state = {"mana": boss.mana}  # Pode adicionar outras variáveis de estado se necessário
	current_state = apply(current_state)  # Aplica a ação e atualiza o estado

	finalize()  # Finaliza a ação
	return true
