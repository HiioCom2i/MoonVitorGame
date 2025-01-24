extends Node2D

@onready var player := $player  # Referência ao jogador
@onready var attack_spawn_area := $spawnArea
@onready var area_de_spawn : Node2D = $spawnArea # PODE REMOVER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("use_medkit"):    # Input "g"   
		atualizando_curas()
		area_de_spawn.spawn_star_areas()
	if Input.is_action_just_pressed("attack"):    # Input "e"   
		atualizando_ataques()

func iniciando_vidas_e_ataques() -> void:
	# Conectando o sinal de cada vida ao método que atualiza seu contador
	for vidas in $vidas.get_children():  # Todas vidas estão no Node2D 'vidas'
		vidas.connect("life_collected", Callable(self, "_on_life_collected"))
	# Conectando o sinal de cada ataque ao método que atualiza seu contador
	for ataque in $spawnArea/listaAtaques.get_children():  # Todos ataques estão no Node2D 'ataques'
		ataque.connect("attack_collected", Callable(self, "_on_attack_collected"))

func iniciando_ataques() -> void:
	# Conectando o sinal de cada ataque ao método que atualiza seu contador
	for ataque in $spawnArea/listaAtaques.get_children():  # Todos ataques estão no Node2D 'ataques'
		ataque.connect("attack_collected", Callable(self, "_on_attack_collected"))

func _on_life_collected():
	player.medKit += 1
	print("vidas coletadas " + str(player.medKit))
	$HUD/container_vida/Controle2/contador_vidas.text = " x " + str(player.medKit)

func _on_attack_collected():
	player.attack += 1
	attack_spawn_area.decrease_qnt_ataques()
	#print("ataques coletado " + str(player.attack))
	$HUD/container_ataque/Controle2/contador_ataques.text = " x " + str(player.attack)

func atualizando_curas() -> void:
	if player.medKit > 0:
		player.vida += 1
		player.medKit-= 1
		$HUD/container_vida/Controle2/contador_vidas.text = " x " + str(player.medKit)
		$HUD/container_vida_persongem/Controle2/contador_coracoes.text = " x " + str(player.vida)

func update_player_hearts() -> void:
		$HUD/container_vida_persongem/Controle2/contador_coracoes.text = " x " + str(player.vida)


func atualizando_ataques() -> void:
	if player.attack > 0:
		player.play_attack_animation()
		player.attack -= 1
		$HUD/container_ataque/Controle2/contador_ataques.text = " x " + str(player.attack)
