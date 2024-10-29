extends CharacterBody2D

@onready var texture := $texture as Sprite2D
@export var SPEED: float = 100.0  # Valor padrão de velocidade

var limEsq: float
var limDir: float
var direction := -1
var initial_position: Vector2

func _ready():
	# Captura a posição inicial e define os limites
	initial_position = position
	limEsq = initial_position.x - 50
	limDir = initial_position.x + 50

func _physics_process(delta: float) -> void:
	# Define a velocidade horizontal sem o fator delta
	velocity.x = direction * SPEED
	
	# Verifica os limites e inverte a direção
	if position.x <= limEsq:
		direction = 1
		texture.flip_h = true  # Ajusta a orientação do sprite
	elif position.x >= limDir:
		direction = -1
		texture.flip_h = false

	# Move o inimigo com base na velocidade
	move_and_slide()
