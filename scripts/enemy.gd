extends CharacterBody2D

@onready var texture := $texture as Sprite2D
@export var SPEED: float = 100.0  # Velocidade padrão de patrulha
@export var CHASE_SPEED: float = 150.0  # Velocidade de perseguição
@export var patrol_texture: Texture2D  # Textura para o modo patrulha
@export var chase_texture: Texture2D   # Textura para o modo perseguição

var limEsq: float
var limDir: float
var direction := -1
var initial_position: Vector2
var is_chasing := false

# Referência para o jogador
var player: BaseCharacter

func _ready():
	# Captura a posição inicial e define os limites
	initial_position = position
	limEsq = initial_position.x - 150
	limDir = initial_position.x + 150
	player = get_tree().get_root().get_node("world-01/player")
	
	# Define a textura inicial para o modo patrulha
	texture.texture = patrol_texture

# Função para iniciar a perseguição
func start_chasing() -> void:
	is_chasing = true
	SPEED = CHASE_SPEED
	texture.texture = chase_texture  # Troca para a textura de perseguição

# Função para parar a perseguição e voltar à patrulha
func stop_chasing() -> void:
	is_chasing = false
	SPEED = 100.0  # Velocidade normal de patrulha
	texture.texture = patrol_texture  # Volta para a textura de patrulha

func _physics_process(delta: float) -> void:
	if is_chasing:
		# Calcula a direção em direção ao jogador
		var direction_to_player = (player.position - position).normalized()
		velocity = direction_to_player * CHASE_SPEED  # Define a velocidade para perseguição
		if (player.position.x - position.x) > 0: # Player está na direita do inimigo
			if direction == -1:
				texture.flip_h = true
		else: # Player está na esquerda 
			if direction == 1:
				texture.flip_h = false
			
	else:
		patrol(delta)

	# Move o inimigo com base na velocidade
	move_and_slide()

# Função para o comportamento de patrulha
func patrol(delta: float) -> void:
	velocity.x = direction * SPEED
	velocity.y = 0
	if position.x <= limEsq:
		direction = 1
		texture.flip_h = true
	elif position.x >= limDir:
		direction = -1
		texture.flip_h = false
