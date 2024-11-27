extends CharacterBody2D

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
var vivo = true
# Referência para o jogador e para o world_01
var player: BaseCharacter
var canAttack = true

func _ready():
	initial_position = position
	limEsq = initial_position.x - 150
	limDir = initial_position.x + 150
	player = get_tree().get_root().get_node("world-01/player")
	reset_enemy()  # Chama a função de reset ao iniciar
	animated_sprite = $textures if has_node("textures") else null
	
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
	if is_chasing:
		chase(delta)
		if enemyAttackArea.overlaps_area(player.hurtbox):
			print("atacou!!")
			attack()
			worldReference.damage_received()
	else:
		patrol(delta)
	move_and_slide()

func patrol(delta: float) -> void:
	if animated_sprite:
		velocity.x = direction * SPEED
		velocity.y = 0
		if position.x <= limEsq:
			direction = 1
			animated_sprite.flip_h = true
		elif position.x >= limDir:
			direction = -1
			animated_sprite.flip_h = false

func chase(delta: float) -> void:
	var direction_to_player = (player.position - position).normalized()
	velocity = direction_to_player * CHASE_SPEED
	if (player.position.x - position.x) > 0: # Player está na direita do inimigo
		if direction == -1:
			animated_sprite.flip_h = true
	else: # Player está na esquerda 
		if direction == 1:
			animated_sprite.flip_h = false

func is_player_nearby() -> bool:
	return is_chasing
	
func attack() -> void:
	print("JINX  " + str(player.vida))
	if canAttack:
		player.vida = player.vida -1;
		canAttack = false
		player.is_death()
		$enemyAttackArea/attackTimer.start(1.0)
	

func _on_attack_timer_timeout() -> void:
	canAttack = true
	

	
	
