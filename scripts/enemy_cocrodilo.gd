extends CharacterBody2D

const BehaviorNode = preload("res://scripts/behavior_tree/behavior_node.gd")
const SequenceNode = preload("res://scripts/behavior_tree/sequence_node.gd")
const SelectorNode = preload("res://scripts/behavior_tree/selection_node.gd")
const ConditionNode = preload("res://scripts/behavior_tree/condition_node.gd")
const ActionNode = preload("res://scripts/behavior_tree/action_node.gd")

const SPEED = 90.0
const CHASE_SPEED = 170.0

var player : BaseCharacter
@onready var worldReference = get_tree().get_root().get_node("world-01")

var desired_velocity = Vector2.ZERO
var distance_to_target = 0.0

var stop_distance = 35.0
var slowing_distance = 100.0
var safe_distance = 500.0

var canAttack = true
var root_node_crocodilo_behavior

func _ready() -> void:
	player = get_tree().get_root().get_node("world-01/player")
	creating_behavior_nodes()
	$cocrodiloAttackArea/attackTimer.connect("timeout", Callable(self, "_on_attackTimer_timeout"))
	if player:
		print("PLAYER DEU BOM")
	
	if !player:
		print("PLAYER NÃO DEU BOM")

func _physics_process(delta: float) -> void:
	distance_to_target = get_distance_to_player()
	root_node_crocodilo_behavior.tick(self)
	move_and_slide()
	update_rotation_to_match_direction()

func update_rotation_to_match_direction() -> void:
	if velocity.length() > 0:  # Apenas ajusta o ângulo se estiver se movendo
		rotation = velocity.angle()
		play_rotation_animation()
	else:
		$animCocrodilo.stop()

func play_rotation_animation() -> void:
	if $animCocrodilo.is_playing() == false:
		$animCocrodilo.play("default")  # Substitua "rotate" pelo nome da animação de rotação

func get_player_attacks() -> int:
	if player != null:
		var ataques = player.get_attack()
		return ataques
	print("tem 0 ataques")
	return 0  # Retorna 0 se o jogador for inválido ou não tiver o método "attack"

func get_distance_to_player() -> float:
	if is_instance_valid(player):  # Verifica se o player é válido
		return position.distance_to(player.position)  # Calcula a distância
	return -1.0  # Retorna infinito se o player não for válido


# Funções de Ação
func seek(delta: float) -> int:
	if not player:
		return BehaviorNode.Status.FAILURE
	var direction_to_player = (player.position - position).normalized()
	velocity = velocity.lerp(direction_to_player * CHASE_SPEED, 0.1)
	move_and_slide()
	print("CROCODILO SEEK")
	return BehaviorNode.Status.SUCCESS

func flee(delta: float) -> int:
	if not player:
		return BehaviorNode.Status.FAILURE
	var direction_away_from_player = (position - player.position).normalized()
	velocity = velocity.lerp(direction_away_from_player * SPEED, 0.1)
	move_and_slide()
	print("CROCODILO FLEE DISTÂNCIA DO ALVO = " + str(distance_to_target))
	return BehaviorNode.Status.SUCCESS

func slow(delta: float) -> int:
	if distance_to_target < slowing_distance:
		desired_velocity = (player.position - position).normalized() * 150.0 * (distance_to_target / slowing_distance)
	else:
		desired_velocity = (player.position - position).normalized() * 150.0
	velocity = velocity.lerp(desired_velocity, delta)
	move_and_slide()
	print("CROCODILO SLOW DESIRED VELOCITY = " + str(desired_velocity))
	return BehaviorNode.Status.SUCCESS

func stop(delta: float) -> int:
	velocity = Vector2.ZERO
	move_and_slide()
	print("CROCODILO STOP")
	return BehaviorNode.Status.SUCCESS

func attack(delta:float) -> int:
	if canAttack and player:
		player.vida -= 1
		canAttack = false
		player.is_death()
		$cocrodiloAttackArea/attackTimer.start(1.0)
		worldReference.update_player_hearts()
		print("CROCODILO ATTACK SUCCESS")
		return BehaviorNode.Status.SUCCESS
	print("CROCODILO ATTACK FAILURE - canAttack: " + str(canAttack))
	return BehaviorNode.Status.FAILURE

func _on_attackTimer_timeout() -> void:
	canAttack = true

# Funções de Condição
func player_can_attack() -> bool: 
	print("CROCODILO CONDIÇÃO TEM ATAQUE " + str(get_player_attacks() > 0))
	return get_player_attacks() > 0 
func player_cannot_attack() -> bool: 
	print("CROCODILO CONDIÇÃO N TEM ATAQUE " + str(get_player_attacks() <= 0))
	return get_player_attacks() <= 0
func crossed_slow_distance() -> bool: 
	print("CROCODILO CONDIÇÃO CRUZOU DIST SLOW")
	return distance_to_target < slowing_distance
func crossed_stop_distance() -> bool: 
	print("CROCODILO CONDIÇÃO CRUZOU DIST STOP " + str(distance_to_target))
	return distance_to_target < stop_distance
func is_in_safe_distance() -> bool: 
	print("CROCODILO CONDIÇÃO TÁ EM DIST SEGURA")
	return distance_to_target >= safe_distance
func is_not_in_safe_distance() -> bool: 
	print("CROCODILO CONDIÇÃO N TÁ EM DIST SEGURA")
	return distance_to_target < safe_distance

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
func attack_wrapper(agent = null, delta: float = 0.0) -> int:
	return attack(delta)
func slow_wrapper(agent = null, delta: float = 0.0) -> int:
	return slow(delta)
func stop_wrapper(agent = null, delta: float = 0.0) -> int:
	return stop(delta)

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
	
