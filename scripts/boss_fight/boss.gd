extends CharacterBody2D

@export var star_spawn_area: Node # Referência à arena do boss
@export var player_path: NodePath
var player: Node = null
# Configurações básicas do boss
var health: int = 20
var mana: float = 0.0
var mana_regeneration_rate: float = 2.0 # Mana regenerada por segundo
var max_mana: float = 100
var star_attack_cooldown_ready = true
var enraged = false
var is_rage_attack_on_cooldown = false
var actions: Array = []

var rage_attack_damage = 10
var rage_attack_range = 40.0  # distância mínima para aplicar dano
var rage_attack_cooldown = 1.5  # tempo em segundos entre danos
var rage_attack_last_hit_time = 0.0
var rage_duration_timer: Timer  # declaração da variável

var rage_attacking = false
var rage_target = null


@export var hand_left: CharacterBody2D
@export var hand_right: CharacterBody2D


# Estados globais do boss
var global_state = {
	#"attack_timer_ready": true,
	"player_in_arena": true
}

func _ready() -> void:
	player = get_node(player_path)
	print("Player setado:", player)
	initialize_actions()
	

	# Configura o timer para regeneração de mana
	var mana_timer = Timer.new()
	mana_timer.wait_time = 1.0 # Chama a cada 1 segundo
	mana_timer.one_shot = false # Repetir indefinidamente
	mana_timer.connect("timeout", Callable(self, "regenerate_mana"))
	add_child(mana_timer)
	mana_timer.start()

	# Configura o timer para o AttackTimer
	var attack_timer = Timer.new()
	attack_timer.wait_time = 5.0 # Cooldown de 5 segundos
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "reset_attack_timer"))
	add_child(attack_timer)

	# Configura o timer para o planejamento da próxima ação
	var plan_timer = Timer.new()
	plan_timer.wait_time = 4.0 # Chama a cada 4 segundos
	plan_timer.one_shot = false # Repetir indefinidamente
	plan_timer.connect("timeout", Callable(self, "plan_next_action"))
	add_child(plan_timer)
	plan_timer.start()
	
	rage_duration_timer = Timer.new()
	rage_duration_timer.wait_time = 5.0  # dura 5 segundos de fúria
	rage_duration_timer.one_shot = true
	rage_duration_timer.connect("timeout", Callable(self, "_on_rage_attack_end"))
	add_child(rage_duration_timer)

func _physics_process(delta):
	#print("rage_attacking:", rage_attacking, "rage_target:", rage_target)

	if rage_attacking and rage_target:
		var direction = (rage_target.global_position - global_position).normalized()
		var speed = 80
		velocity = direction * speed
		#print("Direction:", direction, "Velocity:", velocity)
	else:
		velocity = Vector2.ZERO
		#print("Não está atacando, velocity zerada")

	move_and_slide()  # sem argumentos



# Inicializa as ações do boss
func initialize_actions() -> void:
	var star_attack = BossStarAttack.new(hand_left, hand_right,star_spawn_area, 2, self)
	actions.append(star_attack)

	var hand_attack = BossHandAttack.new(hand_left, hand_right, self, 1) # Dano 20
	actions.append(hand_attack)
	
	var rage_attack = BossRageAttack.new(self, player)
	actions.append(rage_attack)
	
func get_world_state() -> Dictionary:
	return {
		"mana": mana,
		"health": health,
		"attack": false,
		"player_in_arena": global_state["player_in_arena"],
		"star_attack_cooldown_ready": star_attack_cooldown_ready,
		"enraged": enraged
	}

# Planeja a próxima ação usando o A* para maximizar dano
func plan_next_action() -> void:
	var initial_state = get_world_state()
	var goal_state = {"attack": true} # O objetivo é atacar

	var astar = AStarGOAP.new()
	var plan = astar.find_best_plan(actions, initial_state, goal_state)

	if plan.size() > 0:
		execute_plan(plan)
	else:
		print("Nenhum plano encontrado!")

# Executa o plano
func execute_plan(plan: Array) -> void:
	print("Plano gerado:")
	for a in plan:
		print("- Ação:", a.action_name)
	var world_state := get_world_state()
	for action in plan:
		if action.can_execute(world_state):
			print("Executando ação real:", action.action_name)
			print("Objeto da ação:", action)
			print("Mana atual antes da execução:", mana)
			
			action.execute()
			
			print("Mana atual depois da execução:", mana)
			return


# Regenera mana ao longo do tempo
func set_mana(value: int):
	self.mana = clamp(value, 0, max_mana)
	print("Mana atual:", mana)

# Reseta o estado do AttackTimer
func reset_attack_timer() -> void:
	global_state["attack_timer_ready"] = true
	print("attack_timer_ready resetado para True")

# Atualiza o estado do jogador na arena (chamar dinamicamente durante o jogo)
func update_player_in_arena(state: bool) -> void:
	global_state["player_in_arena"] = state

# Regenera mana ao longo do tempo
func regenerate_mana() -> void:
	mana += mana_regeneration_rate
	if mana > max_mana:
		mana = max_mana # Garante que a mana não exceda o máximo
	print("Mana atual:", mana)
	
func take_damage(amount: int) -> void:
	health -= amount
	print("Boss levou ", amount, " de dano! Vida restante: ", health)
	if health <= 10 and not enraged:
		enraged = true
		global_state["enraged"] = true  # <-- atualiza o estado global aqui
		print("O BOSS ESTÁ ENFURECIDO!")
	if health <= 0:
		morrer()
		
func morrer() -> void:
	print("Boss morreu!")
	for part in get_tree().get_nodes_in_group("BossParts"):
		part.die()
	# Aqui você pode colocar animação de morte, emitir sinais, etc
	queue_free()  # Exemplo: remove o boss da cena
	
func start_rage_attack(player):
	# Aqui faz o boss voar pelo mapa atrás do player, por exemplo
	print("Iniciando ataque enfurecido atrás do jogador!")
	rage_attacking = true
	rage_target = player
	rage_duration_timer.start()  # inicia duração da fúria
	
func _on_rage_attack_end():
	rage_attacking = false
	rage_target = null
	print("Ataque de fúria acabou")

func _on_rage_cooldown_timeout():
	is_rage_attack_on_cooldown = false
	
func _apply_rage_damage():
	if rage_target and rage_target.has_method("take_damage"):
		rage_target.take_damage(rage_attack_damage)
		print("Boss aplicou", rage_attack_damage, "de dano de fúria ao player!")	
