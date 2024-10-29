extends CharacterBody2D
class_name BaseCharacter

@export_category("Variables")
@export var _move_speed: float = 128.0

# Variável de direção para movimentação
var _direction: Vector2

# Dicionário para armazenar o estado de cada área
var areas = {
	"Area1": false,
	"Area2": false,
	"Area3": false,
	"Area4": false,
	"Area5": false,
	"Area6": false,
	"Area7": false,
	"Area8": false,
	"Area9": false
}

func _ready() -> void:
	# Conecta o sinal da aura para detecção de proximidade
	$Aura_sapo.connect("area_entered", Callable(self, "_on_aura_entered"))
	$Aura_sapo.connect("area_exited", Callable(self, "_on_aura_exited"))

# Função para lidar com a movimentação do personagem
func _physics_process(_delta: float) -> void:
	# Atualiza a direção com base na entrada
	_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Define a velocidade com base na direção e velocidade de movimento
	velocity = _direction * _move_speed
	move_and_slide()

# Função chamada quando a aura detecta a entrada em uma área
func _on_aura_entered(area: Area2D) -> void:
	# Verifica se a área detectada está no dicionário
	if areas.has(area.name):
		areas[area.name] = true  # Marca a área como prócima
		print_area_states()

# Função chamada quando a aura detecta a saída em uma área
func _on_aura_exited(area: Area2D) -> void:
	# Verifica se a área detectada está no dicionário
	if areas.has(area.name):
		areas[area.name] = false  # Marca a área como distante
		print_area_states()

# Função para exibir o estado atual de todas as áreas
func print_area_states() -> void:
	for i in range(1, 10):
		print(str(i) + ": " + str(areas["Area" + str(i)]))
	print()
	print()
	print()	
		
