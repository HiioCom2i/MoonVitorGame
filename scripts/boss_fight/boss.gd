extends CharacterBody2D

@export var star_spawn_area: Node  # Referência à arena do boss

# Configurações básicas do boss
var health: int = 100
var mana: float = 0.0
var mana_regeneration_rate: float = 5.0  # Mana regenerada por segundo
var max_mana: float = 100
var actions: Array = []  # Ações disponíveis para o boss

func _ready() -> void:
	initialize_actions()
	plan_next_action()
	
	# Configura o timer para regeneração de mana
	var mana_timer = Timer.new()
	mana_timer.wait_time = 1.0  # Chama a cada 1 segundo
	mana_timer.one_shot = false  # Repetir indefinidamente
	mana_timer.connect("timeout", Callable(self, "regenerate_mana"))
	add_child(mana_timer)
	mana_timer.start()

# Inicializa as ações do boss
func initialize_actions() -> void:
	var star_attack = BossStarAttack.new(star_spawn_area)  # Dano: 30
	actions.append(star_attack)

# Planeja a próxima ação usando o A* para maximizar dano
func plan_next_action() -> void:
	var initial_state = {"mana": mana, "health": health}
	var goal_state = {"attack": true}  # O objetivo é atacar
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
func regenerate_mana() -> void:
	mana += mana_regeneration_rate
	if mana > max_mana:
		mana = max_mana  # Garante que a mana não exceda o máximo
	print("Mana atual:", mana)
