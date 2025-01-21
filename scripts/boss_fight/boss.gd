extends CharacterBody2D

@export var star_spawn_area: Node  # Referência à arena do boss

# Configurações básicas do boss
var health: int = 100
var move_speed: float = 200.0
var target_position: Vector2  # Posição do alvo para perseguição ou ataque

# Referências e ações
var actions: Array = []  # Lista de ações disponíveis para o boss

# Sinal para avisar quando o boss iniciar um ataque
signal attack_started(action_name: String)

func _ready() -> void:
	# Configurações iniciais
	initialize_actions()

func _process(delta: float) -> void:
	# Loop de comportamento do boss
	execute_behavior(delta)


# Inicializa as ações disponíveis do boss
func initialize_actions() -> void:
	var star_attack = BossStarAttack.new(star_spawn_area)
	star_attack.cost = 5
	star_attack.preconditions = {"player_in_arena": true}
	star_attack.effects = {"player_damaged": true}
	actions.append(star_attack)

# Executa o comportamento do boss
func execute_behavior(delta: float) -> void:
	if health > 50:
		# Decisão: escolher e executar uma ação
		perform_action("BossStarAttack")
	else:
		print("Boss está ferido e mudando comportamento.")

# Realiza uma ação específica com base no nome
func perform_action(action_name: String) -> void:
	for action in actions:
		if action.get_class() == action_name:
			emit_signal("attack_started", action_name)
			if action.execute():
				print("Ação executada com sucesso:", action_name)
				action.finalize()
			else:
				print("Falha ao executar a ação:", action_name)
			return

# Recebe dano do jogador
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()
	else:
		print("Boss sofreu dano! Vida restante: ", health)

# Função de morte do boss
func die() -> void:
	print("Boss derrotado!")
	queue_free()

# Chamado por `BossStarAttack` para fazer algo com base no ataque
func on_star_attack_effect() -> void:
	print("Efeito do StarAttack foi ativado!")
