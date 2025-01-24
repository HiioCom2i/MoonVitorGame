class_name BossHandAttack
extends GOAPAction

var hand_left: CharacterBody2D
var hand_right: CharacterBody2D
var boss: CharacterBody2D
var damage: float  # Defina o dano aqui
var action_name = "BossHandAttack"
var cooldown_time = 4.0  # Tempo de cooldown em segundos
var is_in_cooldown = false

func _init(hand_left: CharacterBody2D, hand_right: CharacterBody2D, boss: CharacterBody2D, damage: float):
	self.hand_left = hand_left  # Configura a mão esquerda
	self.hand_right = hand_right  # Configura a mão direita
	self.boss = boss  # Configura o boss
	self.damage = damage  # Inicialize o dano
	action_name = "BossHandAttack"
	
	# Define as pré-condições e efeitos específicos da ação
	preconditions = {
		"mana": {"operator": "<", "value": 60},
	}
	effects = {
		"mana_restored": true,  # O efeito desejado é restaurar a mana
		"attack": true
	}

	cost = -damage  # O custo é o dano em negativo para priorizar ataques mais poderosos

# Método para aplicar os efeitos da ação
func apply(state: Dictionary) -> Dictionary:
	#if is_running:
		#print("BossHandAttack ainda está em execução, ignorando apply.")
		#return state

	print("Simulando BossHandAttack no apply!")

	# Simula os efeitos da ação no estado local
	var new_state = state.duplicate()
	#new_state["mana"] = min(boss.mana + 20, boss.max_mana)  # Simula restauração de mana
	new_state["attack"] = true  # Define que um ataque está planejado
	return new_state

# Método para executar a ação
func execute() -> bool:
	# Verifica se o ataque está em cooldown ou se outro ataque já está ativo
	#if is_running or boss.global_state.get("attack", false):
		#print("Outro ataque está em andamento.")
		#return false

	if is_in_cooldown:
		print("BossHandAttack está em cooldown, aguardando.")
		return false

	print("Executou o BossHandAttack")
	
	# Define o estado do ataque como em andamento
	is_running = true
	boss.global_state["attack"] = true

	# Restaura mana real
	boss.set_mana(boss.mana + 20)

	# Executa o ataque das mãos
	if hand_left and hand_left is CharacterBody2D:
		hand_left.attack()
		if not hand_left.is_connected("attack_finished", Callable(self, "_on_attack_finished")):
			hand_left.connect("attack_finished", Callable(self, "_on_attack_finished"))
	else:
		print("Erro: Mão esquerda não configurada ou inválida.")
		
	if hand_right and hand_right is CharacterBody2D:
		hand_right.attack()
		if not hand_right.is_connected("attack_finished", Callable(self, "_on_attack_finished")):
			hand_right.connect("attack_finished", Callable(self, "_on_attack_finished"))
	else:
		print("Erro: Mão direita não configurada ou inválida.")
		
	# Inicia cooldown
	_start_cooldown()
	return true
func _start_cooldown() -> void:
	is_in_cooldown = true
	await Engine.get_main_loop().create_timer(cooldown_time).timeout
	is_in_cooldown = false
	print("Cooldown do BossHandAttack finalizado.")
# Callback chamado quando o ataque termina
func _on_attack_finished() -> void:
	if hand_left and hand_left.is_connected("attack_finished", Callable(self, "_on_attack_finished")):
		hand_left.disconnect("attack_finished", Callable(self, "_on_attack_finished"))
	if hand_right and hand_right.is_connected("attack_finished", Callable(self, "_on_attack_finished")):
		hand_right.disconnect("attack_finished", Callable(self, "_on_attack_finished"))

	print("Ataque finalizado, chamando finalize()")
	finalize()

# Finaliza a ação e redefine estados
func finalize() -> void:
	print("Finalizando BossHandAttack!")
	is_running = false
	boss.global_state["attack"] = false
