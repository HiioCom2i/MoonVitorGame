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

func _physics_process(delta: float) -> void:
	move_and_slide()

# Seek do comportamento para ajustar velocidade gradativamente
func seek(delta: float) -> int:
	if not player or not player.is_valid():
		return BehaviorNode.Status.FAILURE
	
	# Calcular a direção do inimigo para o jogador
	var direction_to_player = (player.position - position).normalized()
	var desired_velocity = direction_to_player * CHASE_SPEED
	
	# Ajustar a velocidade gradativamente
	velocity = velocity.lerp(desired_velocity, 0.1)  # O valor 0.1 controla a suavidade	
	return BehaviorNode.Status.SUCCESS

func arrive(delta: float) -> void:
	if not player or not player.is_valid():
		velocity = Vector2.ZERO
		return

	var target_position = player.position
	var desired_velocity = target_position - position
	var distance_to_target = desired_velocity.length()

	# Se o inimigo estiver perto do suficiente do alvo, ele para
	if distance_to_target < 5.0:  # Raio de parada
		velocity = Vector2.ZERO
		return

	# Ajustar a velocidade desejada conforme a distância
	var max_speed = 150.0  # Velocidade máxima
	var slowing_radius = 100.0  # Raio de desaceleração
	if distance_to_target < slowing_radius:
		desired_velocity = desired_velocity.normalized() * max_speed * (distance_to_target / slowing_radius)
	else:
		desired_velocity = desired_velocity.normalized() * max_speed

	# Ajustar gradualmente a velocidade
	var steering = desired_velocity - velocity
	var max_force = 200.0  # Máxima força de ajuste
	if steering.length() > max_force:
		steering = steering.normalized() * max_force

	velocity += steering * delta


func creating_behavior_nodes() -> void:
	var node_action_seek = ActionNode.new(Callable(self, "seek"))
	var node_action_arrive = ActionNode.new(Callable(self, "arrive"))
