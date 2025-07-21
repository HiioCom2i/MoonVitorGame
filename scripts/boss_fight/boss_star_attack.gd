class_name BossStarAttack
extends GOAPAction

var spawn_area: Node
var damage: float
var boss: CharacterBody2D
var action_name = "BossStarAttack"
var cooldown_time = 8.0
var is_in_cooldown = false

var hand_left: CharacterBody2D
var hand_right: CharacterBody2D


func _init(hand_left: CharacterBody2D, hand_right: CharacterBody2D, spawn_node: Node, damage: float, boss: CharacterBody2D):
	self.hand_left = hand_left  # Configura a mão esquerda
	self.hand_right = hand_right  # Configura a mão direita
	self.spawn_area = spawn_node
	self.damage = damage
	self.boss = boss
	action_name = "BossStarAttack"
	
	# Define as pré-condições e efeitos específicos da ação
	preconditions = {
		"mana": {"operator": ">=", "value": 60},
	}

	effects = {
		"attack": true,
	}
	
	# Configuração do custo
	cost = -damage  # Ajuste o valor base conforme necessário


# Simula os efeitos da ação
func apply(state: Dictionary) -> Dictionary:
	if not spawn_area:
		print("Erro: Nodo de spawn não foi inicializado corretamente!")
		return state
	
	print("Simulando BossStarAttack no apply!")
	var new_state = state.duplicate()
	new_state["mana"] = max(0, new_state["mana"] - 60)  # Simula a redução de mana
	new_state["attack"] = true
	return new_state

# Executa a ação
func execute() -> bool:
	#if is_running:
		#print("Outro ataque está em andamento.")
		#return false

	if is_in_cooldown:
		print("BossStarAttack está em cooldown.")
		return false

	if boss.mana < 60:
		print("Mana insuficiente para BossStarAttack.")
		return false

	# Define estados globais e consome mana real
	print("Executando BossStarAttack!")
	is_running = true
	boss.global_state["attack"] = true
	boss.set_mana(boss.mana - 60)
	
	print("Mana consumida para BossStarAttack. Mana atual:", boss.mana)
	if hand_left and hand_left is CharacterBody2D:
		hand_left.attackStar()
		if not hand_left.is_connected("attack_finished", Callable(self, "_on_attack_finished")):
			hand_left.connect("attack_finished", Callable(self, "_on_attack_finished"))
	else:
		print("Erro: Mão esquerda não configurada ou inválida.")
		
	if hand_right and hand_right is CharacterBody2D:
		hand_right.attackStar()
		if not hand_right.is_connected("attack_finished", Callable(self, "_on_attack_finished")):
			hand_right.connect("attack_finished", Callable(self, "_on_attack_finished"))
	else:
		print("Erro: Mão direita não configurada ou inválida.")
	# Conecta e executa spawn de estrelas
	if spawn_area and spawn_area.has_method("spawn_star_areas"):
		_connect_star_areas_signal()
		spawn_area.spawn_star_areas()
	else:
		print("Erro: Nodo de spawn inválido ou método não encontrado!")
		finalize()
		return false

	_start_cooldown()
	return true

# Inicia o cooldown
func _start_cooldown() -> void:
	is_in_cooldown = true
	await Engine.get_main_loop().create_timer(cooldown_time).timeout
	is_in_cooldown = false
	print("Cooldown do BossStarAttack finalizado.")

# Finaliza a ação
func finalize() -> void:
	print("BossStarAttack finalizada.")
	is_running = false
	boss.global_state["attack"] = false
	

# Callback chamado ao finalizar a ação
func _on_star_areas_finished() -> void:
	print("Todas as áreas explosivas foram concluídas!")
	_disconnect_star_areas_signal()
	finalize()

# Conecta o sinal de finalização das estrelas
func _connect_star_areas_signal() -> void:
	if spawn_area and not spawn_area.is_connected("star_areas_finished", Callable(self, "_on_star_areas_finished")):
		spawn_area.connect("star_areas_finished", Callable(self, "_on_star_areas_finished"))

# Desconecta o sinal de finalização das estrelas
func _disconnect_star_areas_signal() -> void:
	if spawn_area and spawn_area.is_connected("star_areas_finished", Callable(self, "_on_star_areas_finished")):
		spawn_area.disconnect("star_areas_finished", Callable(self, "_on_star_areas_finished"))
