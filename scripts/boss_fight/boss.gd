extends CharacterBody2D

@export var star_spawn_area: Node  # Referência à arena do boss

# Configurações básicas do boss
var health: int = 100
var mana: float = 50
var max_mana: float = 100
var actions: Array = []  # Ações disponíveis para o boss

func _ready() -> void:
	initialize_actions()
	plan_next_action()

# Inicializa as ações do boss
func initialize_actions() -> void:
	var star_attack = BossStarAttack.new(star_spawn_area)  # Dano: 30
	actions.append(star_attack)
	#var smash_attack = BossSmashAttack.new(50)  # Dano: 50
	#actions.append(smash_attack)

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
