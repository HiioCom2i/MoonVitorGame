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
#@onready var worldReference = get_tree().get_root().get_node("world-01") # Referência para o mundo
 
@onready var desired_velocity = get_player_position() - position
@onready var distance_to_target = desired_velocity.length() # Vetor de direção para o jogador

var stop_distance = 5.0 # Distância de parada
var slowing_distance = 100.0  # Distância de desaceleração
var safe_distance = 500.0  # Distância segura do jacaré em relação ao player

func _physics_process(delta: float) -> void:
	move_and_slide()

func get_player_attacks() -> int:
	var attacks = 0
	if player.has_method("attack"):
		attacks = player.attack
	return player and player.is_valid() and attacks

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

func creating_behavior_nodes() -> void:
	var node_action_seek = ActionNode.new(Callable(self, "seek"))
	var node_action_slow = ActionNode.new(Callable(self, "slow"))
	var node_action_stop = ActionNode.new(Callable(self, "slow"))
	
	var node_condition_can_attack = ConditionNode.new(Callable(self, "player_can_attack"))
	var node_condition_cannot_attack = ConditionNode.new(Callable(self, "player_cannot_attack"))
	var node_condition_crossed_slow_distance = ConditionNode.new(Callable(self, "crossed_slow_distance"))
	var node_condition_crossed_stop_distance = ConditionNode.new(Callable(self, "crossed_stop_distance"))
	var node_condition_in_safe_distance = ConditionNode.new(Callable(self, "is_in_safe_distance"))
	var node_condition_not_in_safe_distance = ConditionNode.new(Callable(self, "is_not_in_safe_distance"))
