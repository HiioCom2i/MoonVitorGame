extends CharacterBody2D

# Importando as classes dos nós de comportamento
const BehaviorNode = preload("res://scripts/behavior_tree/behavior_node.gd")
const SequenceNode = preload("res://scripts/behavior_tree/sequence_node.gd")
const SelectorNode = preload("res://scripts/behavior_tree/selection_node.gd")
const ConditionNode = preload("res://scripts/behavior_tree/condition_node.gd")
const ActionNode = preload("res://scripts/behavior_tree/action_node.gd")
const WhileFailDecorator = preload("res://scripts/behavior_tree/while_fail_decorator.gd")
const WhileSuccessDecorator = preload("res://scripts/behavior_tree/while_success_decorator.gd")

const SPEED = 90.0
const CHASE_SPEED = 170.0
const JUMP_VELOCITY = -400.0

var player: BaseCharacter # Referência para o jogador
@onready var worldReference = get_tree().get_root().get_node("world-01") # Referência para o mundo
 
@onready var desired_velocity = get_player_position() - position
@onready var distance_to_target = desired_velocity.length() # Vetor de direção para o jogador

var stop_distance = 1.0 # Distância de parada
var slowing_distance = 100.0  # Distância de desaceleração
var safe_distance = 500.0  # Distância segura do jacaré em relação ao player

var canAttack = true

var root_node_crocodilo_behavior

func _ready() -> void:
	creating_behavior_nodes()

func _physics_process(delta: float) -> void:
	root_node_crocodilo_behavior.tick(self) # Chamando nó raiz da árvore de comportamento
	
	move_and_slide()

func get_player_attacks() -> int:
	if player and player.is_valid():
		if player.has_method("attack"):
			return player.attack
	return 0  # Retorna 0 se o jogador for inválido ou não tiver o método "attack"

func get_player_position() -> Vector2:
	var position_var = position
	if player and player.is_valid() and player.has_method("get_position"):
		position_var = player.position
	return position_var


# Funções de Ação
func seek(delta: float) -> int:
	if not player or not player.is_valid():
		return BehaviorNode.Status.FAILURE
	
	# Calcular a direção do inimigo para o jogador
	var direction_to_player = (player.position - position).normalized()
	var desired_velocity = direction_to_player * CHASE_SPEED
	
	# Ajustar a velocidade gradativamente
	velocity = velocity.lerp(desired_velocity, 0.1)  # O valor 0.1 controla a suavidade	
	return BehaviorNode.Status.SUCCESS
func flee(delta: float) -> int:
	if not player or not player.is_valid():
		return BehaviorNode.Status.FAILURE

	# Calcular a direção oposta ao jogador
	var direction_away_from_player = (position - player.position).normalized()
	var desired_velocity = direction_away_from_player * SPEED

	# Ajustar a velocidade gradativamente
	velocity = velocity.lerp(desired_velocity, 0.1)  # O valor 0.1 controla a suavidade da mudança de velocidade
	
	# Mover o inimigo
	move_and_slide()
	
	return BehaviorNode.Status.SUCCESS
func attack() -> int:
	if canAttack and player and player.is_valid():
		player.vida -= 1
		canAttack = false
		player.is_death()
		$cocrodiloAttackArea/attackTimer.start(1.0)
		print("Crocodilo atacou! Vida do jogador: ", player.vida)
		worldReference.update_player_hearts()
		return BehaviorNode.Status.SUCCESS
	return BehaviorNode.Status.FAILURE
func slow(delta: float) -> void:
	# Ajustar a velocidade desejada conforme a distância
	var max_speed = 150.0  # Velocidade máxima
	if distance_to_target < slowing_distance:
		desired_velocity = desired_velocity.normalized() * max_speed * (distance_to_target / slowing_distance)
	else:
		desired_velocity = desired_velocity.normalized() * max_speed
	
	# Ajustar gradualmente a velocidade
	var steering = desired_velocity - velocity
	var max_force = 200.0  # Máxima força de ajuste
	if steering.length() > max_force:
		steering = steering.normalized() * max_force
	
	velocity += steering * delta
func stop(delta: float) -> void: velocity = Vector2.ZERO

# Funções de Condição
func player_can_attack() -> bool: return get_player_attacks() > 0
func player_cannot_attack() -> bool: return get_player_attacks() <= 0
func crossed_slow_distance() -> bool: return distance_to_target < slowing_distance
func crossed_stop_distance() -> bool: return distance_to_target < stop_distance
func is_in_safe_distance() -> bool: return distance_to_target >= safe_distance
func is_not_in_safe_distance() -> bool: return distance_to_target < safe_distance

# Wrappers das Funções de Condição
func player_can_attack_wrapper(agent = null) -> bool:
	return player_can_attack()
func player_cannot_attack_wrapper(agent = null) -> bool:
	return player_cannot_attack()
func crossed_slow_distance_wrapper(agent = null) -> bool:
	return crossed_slow_distance()
func crossed_stop_distance_wrapper(agent = null) -> bool:
	return crossed_stop_distance()
func is_in_safe_distance_wrapper(agent = null) -> bool:
	return is_in_safe_distance()
func is_not_in_safe_distance_wrapper(agent = null) -> bool:
	return is_not_in_safe_distance()

# Wrappers das Funções de Ação
func seek_wrapper(agent = null, delta: float = 0.0) -> int:
	return seek(delta)
func flee_wrapper(agent = null, delta: float = 0.0) -> int:
	return flee(delta)
func attack_wrapper(agent = null) -> int:
	return attack()
func slow_wrapper(agent = null, delta: float = 0.0) -> void:
	slow(delta)
func stop_wrapper(agent = null, delta: float = 0.0) -> void:
	stop(delta)

func creating_behavior_nodes() -> void:
	var node_action_seek = ActionNode.new(Callable(self, "seek_wrapper"))
	var node_action_flee = ActionNode.new(Callable(self, "flee_wrapper"))
	var node_action_attack = ActionNode.new(Callable(self, "attack_wrapper"))
	var node_action_slow = ActionNode.new(Callable(self, "slow_wrapper"))
	var node_action_stop = ActionNode.new(Callable(self, "stop_wrapper"))
	
	var node_condition_can_attack = ConditionNode.new(Callable(self, "player_can_attack_wrapper"))
	var node_condition_cannot_attack = ConditionNode.new(Callable(self, "player_cannot_attack_wrapper"))
	var node_condition_crossed_slow_distance = ConditionNode.new(Callable(self, "crossed_slow_distance_wrapper"))
	var node_condition_crossed_stop_distance = ConditionNode.new(Callable(self, "crossed_stop_distance_wrapper"))
	var node_condition_in_safe_distance = ConditionNode.new(Callable(self, "is_in_safe_distance_wrapper"))
	var node_condition_not_in_safe_distance = ConditionNode.new(Callable(self, "is_not_in_safe_distance_wrapper"))
	
	var node_sequence_wait = SequenceNode.new([node_condition_in_safe_distance, node_action_stop])
	var node_sequence_run_away = SequenceNode.new([node_condition_not_in_safe_distance, node_action_flee])
	var node_sequence_slow = SequenceNode.new([node_condition_crossed_slow_distance, node_action_slow, 
												node_condition_crossed_stop_distance, node_action_stop])
	
	var node_selection_wait_or_run_away = SelectorNode.new([node_sequence_wait, node_sequence_run_away])
	
	var node_sequence_escape = SequenceNode.new([node_condition_can_attack, node_selection_wait_or_run_away])
	var node_sequence_attack = SequenceNode.new([node_condition_crossed_stop_distance, node_action_attack])
	var node_sequence_seek = SequenceNode.new([node_condition_cannot_attack, node_action_seek, 
												node_sequence_slow])
	
	var node_selection_escape_or_attack_or_seek = SelectorNode.new([node_sequence_escape, node_sequence_attack,
																	node_sequence_seek])
	
	root_node_crocodilo_behavior = SequenceNode.new([node_selection_escape_or_attack_or_seek])
	
