extends CharacterBody2D
class_name BaseCharacter

@export_category("Variables")
@export var _move_speed: float
@onready var anim := $idle_anim as AnimatedSprite2D


var _direction: Vector2 # Variável de direção para movimentação
var vida = 5
@onready var hurtbox := $hurtbox as Area2D


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
	# Conecta o sinal da aura para detecção de proximidade das áreas
	$Aura_sapo.connect("area_entered", Callable(self, "_on_aura_entered"))
	$Aura_sapo.connect("area_exited", Callable(self, "_on_aura_exited"))
	
	# Conecta o sinal da aura para o spawn de inimigos
	$Aura_sapo_distancia.connect("area_entered", Callable(self, "_on_area_entered"))
	
	# Conectar o sinal "animation_finished" para saber quando o ataque termina
	$ataque_anim.connect("animation_finished", Callable(self, "_on_attack_animation_finished"))
	
	


# Função para lidar com a movimentação do personagem
func _physics_process(_delta: float) -> void:
	# Atualiza a direção com base na entrada
	_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Define a velocidade com base na direção e velocidade de movimento
	velocity = _direction * _move_speed
	if _direction.x == 1:
		anim.flip_h = true
		$ataque_anim.flip_h = true # Flip da animação de ataque (atualmente invisível)
	if _direction.x == -1:
		anim.flip_h = false
		$ataque_anim.flip_h = false # Flip da animação de ataque (atualmente invisível)
	move_and_slide()

# Função chamada quando a aura detecta a entrada em uma área
func _on_aura_entered(area: Area2D) -> void:
	# Verifica se a área detectada está no dicionário
	if areas.has(area.name):
		areas[area.name] = true  # Marca a área como próxima
		for ini in area.enemies:
			print("inimigos dentro dessa área: " + ini.name)
		print_area_states()
	if area.has_method("activate_enemies"):
		area.activate_enemies()  # Ativa estado de perseguição
		print("inimigos ativados")

# Função chamada quando a aura detecta a saída em uma área
func _on_aura_exited(area: Area2D) -> void:
	# Verifica se a área detectada está no dicionário
	if areas.has(area.name):
		areas[area.name] = false  # Marca a área como distante
	if area.has_method("deactivate_enemies"):
		area.deactivate_enemies()  # Desativa os inimigos na área

# Função para exibir o estado atual de todas as áreas
func print_area_states() -> void:
	for i in range(1, 10):
		print(str(i) + ": " + str(areas["Area" + str(i)]))
	print()
	print()
	print()	
		

# Função para iniciar a animação de ataque
func play_attack_animation():
	$idle_anim.visible = false   # Desativar idle
	$ataque_anim.visible = true  # Ativar ataque
	$ataque_anim.play("default") # Tocar a animação de ataque uma vez
	

# Função chamada quando a animação de ataque termina ()
func _on_attack_animation_finished():
	$ataque_anim.visible = false  # Desativar ataque
	$idle_anim.visible = true     # Reativar idle
	$idle_anim.play("default")    # Tocar a animação de idle
	
func is_death() -> void:
	if vida <= 0:
		queue_free()
