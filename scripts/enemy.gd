extends CharacterBody2D

# Importando as classes dos nós de comportamento
const BehaviorNode = preload("res://scripts/behavior_tree/behavior_node.gd")
const SequenceNode = preload("res://scripts/behavior_tree/sequence_node.gd")
const SelectorNode = preload("res://scripts/behavior_tree/selection_node.gd")
const ConditionNode = preload("res://scripts/behavior_tree/condition_node.gd")
const ActionNode = preload("res://scripts/behavior_tree/action_node.gd")
const WhileFailDecorator = preload("res://scripts/behavior_tree/while_fail_decorator.gd")
const WhileSuccessDecorator = preload("res://scripts/behavior_tree/while_success_decorator.gd")


@onready var animated_sprite := $AnimatedSprite2D  # Referência ao AnimatedSprite2D
@onready var enemyAttackArea := $enemyAttackArea as Area2D
@onready var worldReference = get_tree().get_root().get_node("world-01")
@export var SPEED: float = 100.0  # Velocidade padrão de patrulha
@export var CHASE_SPEED: float = 150.0  # Velocidade de perseguição
@export var area: Area2D # Área da qual o inimigo pertence

var limEsq: float # Limite de patrulha
var limDir: float # Limite de patrulha
var direction := -1 # Direção - Esquerda: -1 Direita: 1
var initial_position: Vector2 
var is_chasing := false 
var is_in_range := false
var vivo = true
var player: BaseCharacter # Referência para o jogador
var canAttack = true
var root_node_enemy_behavior # Nó raiz de árvore de comportamento 

func _ready():
	initial_position = position
	limEsq = initial_position.x - 150
	limDir = initial_position.x + 150
	player = get_tree().get_root().get_node("world-01/player")
	reset_enemy()  # Chama a função de reset ao iniciar
	animated_sprite = $textures if has_node("textures") else null
	creating_enemy_behavior_tree() # Função que estrutura os nós da árvore de comportamento


	
func reset_enemy():
	is_chasing = false
	direction = -1
	SPEED = 100.0
	position = initial_position
	animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null  # Redefine a referência
	if animated_sprite:
		animated_sprite.frame = 0
		animated_sprite.flip_h = direction

func start_chasing() -> void:
	is_chasing = true
	SPEED = CHASE_SPEED
	if animated_sprite:
		animated_sprite.frame = 1

func stop_chasing() -> void:
	is_chasing = false
	SPEED = 100.0
	if animated_sprite:
		animated_sprite.frame = 0

func _physics_process(delta: float) -> void:
	# Verificar se o jogador ainda existe antes de acessar a hitbox
	if player != null and player.has_node("hurtbox"):
		# Atualizar `is_in_range` baseado na sobreposição
		is_in_range = enemyAttackArea.overlaps_area(player.hurtbox)
	else:
		is_in_range = false  # Caso o jogador não exista ou não tenha a hitbox, não há sobreposição

	
	# Chamar o comportamento baseado na árvore de comportamento
	root_node_enemy_behavior.tick(self)  # Atualiza a árvore de comportamento com o "agent" sendo o inimigo
	
	# Movimentação com base na velocidade calculada pela árvore
	move_and_slide()


func patrol(delta: float) -> int:
	if position.x <= limEsq:
		direction = 1
		animated_sprite.flip_h = true
	elif position.x >= limDir:
		direction = -1
		animated_sprite.flip_h = false
	
	velocity.x = direction * SPEED
	velocity.y = 0
	
	return BehaviorNode.Status.SUCCESS

func chase(delta: float) -> int:
	var direction_to_player = (player.position - position).normalized()
	velocity = direction_to_player * CHASE_SPEED
	
	# Atualiza a direção do sprite
	if (player.position.x - position.x) > 0: # Player está na direita
		if direction == -1:
			animated_sprite.flip_h = true
	else: # Player está na esquerda
		if direction == 1:
			animated_sprite.flip_h = false
	
	return BehaviorNode.Status.SUCCESS

func attack() -> int:
	if canAttack:
		player.vida -= 1
		canAttack = false
		player.is_death()
		$enemyAttackArea/attackTimer.start(1.0)
		print("Inimigo atacou! Vida do jogador: ", player.vida)
		worldReference.damage_received()
		return BehaviorNode.Status.SUCCESS
	return BehaviorNode.Status.FAILURE

func _on_attack_timer_timeout() -> void: canAttack = true

func is_player_nearby() -> bool: return is_chasing

func is_player_distant() -> bool: return not is_chasing

func is_in_attack_range() -> bool: return is_in_range

func is_player_alive() -> bool:
	if player != null and player.vida > 0:
		return true
	return false

# Wrappers necessários para a estrutura de SUCCESS, FAILURE e RUNNING funcionarem com funções daqui
func is_player_nearby_wrapper(agent) -> bool: return is_player_nearby()

func is_player_distant_wrapper(agent) -> bool: return is_player_distant()

func is_player_alive_wrapper(agent) -> bool: return is_player_alive()

func is_in_attack_range_wrapper(agent) -> bool: return is_in_attack_range()

func attack_wrapper(agent) -> int:
	attack()
	return BehaviorNode.Status.SUCCESS

func chase_wrapper(agent) -> int:
	chase(get_process_delta_time())
	return BehaviorNode.Status.SUCCESS

func patrol_wrapper(agent) -> int:
	patrol(get_process_delta_time())
	return BehaviorNode.Status.SUCCESS

func creating_enemy_behavior_tree() -> void:
	# Nós de comportamento - estruturando a árvore
	var node_action_patrol = ActionNode.new(Callable(self, "patrol_wrapper"))
	var node_action_chase = ActionNode.new(Callable(self, "chase_wrapper"))
	var node_action_attack = ActionNode.new(Callable(self, "attack_wrapper"))
	
	var node_conditiion_player_nearby = ConditionNode.new(Callable(self, "is_player_nearby_wrapper"))
	var node_condition_player_distant = ConditionNode.new(Callable(self, "is_player_distant_wrapper"))
	var node_conditiion_attack_in_range = ConditionNode.new(Callable(self, "is_in_attack_range_wrapper"))
	var node_conditiion_player_alive = ConditionNode.new(Callable(self, "is_player_alive_wrapper"))
	
	# Nós de sequência (com decorador)
	var node_sequence_attack_player = SequenceNode.new([node_conditiion_attack_in_range, 
	node_action_attack, node_conditiion_player_alive])
	# RUS - Repeat Until Success - Repetir até sucesso
	var node_RUS_attack_player = WhileSuccessDecorator.new(node_sequence_attack_player) # Decorador
	var node_sequence_back_to_patrol = SequenceNode.new([node_condition_player_distant, root_node_enemy_behavior])
	
	# Nó de seleção
	var node_selection_attack_or_patrol = SelectorNode.new([node_sequence_back_to_patrol, node_RUS_attack_player]) 
	
	root_node_enemy_behavior = SequenceNode.new([
		node_action_patrol,
		node_conditiion_player_nearby,
		node_action_chase,
		node_selection_attack_or_patrol])
