extends CharacterBody2D

@export var star_spawn_area: Node # Referência à arena do boss

# Configurações básicas do boss
var initial_state = {
	"mana": 0,
	"health": 20,
	"attack_timer_ready": true,  # Atualizado
	"player_in_arena": true      # Atualizado
}

var health: int = 20
var mana: float = 0.0
var mana_regeneration_rate: float = 0.0 # Mana regenerada por segundo
var max_mana: float = 60
var actions: Array = []


@export var hand_left: CharacterBody2D
@export var hand_right: CharacterBody2D

# Estados globais do boss
var global_state = {
	#"attack_timer_ready": true,
	"player_in_arena": true
}

func _ready() -> void:
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

# Inicializa as ações do boss
func initialize_actions() -> void:
	var star_attack = BossStarAttack.new(star_spawn_area, 2, self)
	actions.append(star_attack)

	var hand_attack = BossHandAttack.new(hand_left, hand_right, self, 1) # Dano 20
	actions.append(hand_attack)

# Planeja a próxima ação usando o A* para maximizar dano
func plan_next_action() -> void:
	var initial_state = {
		"mana": mana,
		"health": health,
		#"attack_timer_ready": global_state["attack_timer_ready"],
		"attack": false,
		"player_in_arena": global_state["player_in_arena"]
	}
	var goal_state = {"attack": true} # O objetivo é atacar

	var astar = AStarGOAP.new()
	var plan = astar.find_best_plan(actions, initial_state, goal_state)

	if plan.size() > 0:
		execute_plan(plan)
	else:
		print("Nenhum plano encontrado!")

# Executa o plano
func execute_plan(plan: Array) -> void:
	for action in plan:
		if action.can_execute({"mana": mana, "health": health}):
			action.execute()
			print("Executando ação:", action.get_class())

			return

# Regenera mana ao longo do tempo
func set_mana(value: int):
	self.mana = clamp(value, 0, 60)  # Ajusta entre 0 e o máximo de 60
	print("Mana atual: ", mana)

# Reseta o estado do AttackTimer
func reset_attack_timer() -> void:
	global_state["attack_timer_ready"] = true
	print("attack_timer_ready resetado para True")

# Atualiza o estado do jogador na arena (chamar dinamicamente durante o jogo)
func update_player_in_arena(state: bool) -> void:
	global_state["player_in_arena"] = state
