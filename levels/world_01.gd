extends Node2D

@export var enemy_scene: PackedScene  # A cena base do inimigo
@onready var player := $player  # Referência ao jogador
@onready var aura_spawn_de_ini := $player/Aura_sapo_distancia  # Aura do jogador que detecta sua proximidade aos inimigos
@onready var aura_prox_area := $player/Aura_sapo  # Aura do jogador que detecta sua proximidade às áreas
@onready var world := get_parent()  # Referência ao nó pai (World_01)

var medkits = 1    # usados para recuperar corações
var attacks = 2    # usado para atacar
var enemy_data = []  # Lista para armazenar informações dos inimigos

func _ready():
	# Captura informações dos inimigos e os remove da cena
	for enemy in $inimigos.get_children():
		var enemy_info = {
			"position": enemy.position,
			"name": enemy.name,
			"chase_speed": enemy.CHASE_SPEED,
			"patrol_speed": enemy.SPEED,
			"is_chasing": enemy.is_chasing,
			"area": enemy.area,
		}
		enemy_data.append(enemy_info)
		enemy.queue_free()  # Remove o inimigo da cena após salvar informações
	
	for area in $"Áreas".get_children():
		area.enemies.clear()
	
	# Conectando o sinal de entrada na área da aura
	aura_spawn_de_ini.connect("area_entered", Callable(self, "_on_aura_distance_trigger"))
	# Configura a `collision_mask` da aura de spawn para que detecte apenas a camada de spawn (camada 7)
	aura_spawn_de_ini.collision_mask = 1 << 6  # A camada 7 

	# Criando áreas de spawn para cada inimigo
	for enemy_info in enemy_data:
		create_enemy_spawn_box(enemy_info["position"])
	
	iniciando_vidas_e_ataques() # Inicia os itens de vida e ataque

func _process(delta: float) -> void: # Função pra definir os comandos das binds
	if Input.is_action_just_pressed("use_medkit"):    # Input "g"   
		iniciando_comando_cura()
	if Input.is_action_just_pressed("attack"):    # Input "e"   
		iniciando_comando_ataque()

# Função para criar uma área invisível de spawn para o inimigo
func create_enemy_spawn_box(position: Vector2) -> void:
	var spawn_area = Area2D.new()
	spawn_area.name = "EnemySpawnArea_" + str(position)  # Nome único para cada área de spawn com base na posição
	spawn_area.position = position
	
	# Configura a `collision_layer` para que este ponto de spawn esteja na camada 7
	spawn_area.collision_layer = 1 << 6  # Camada 7 

	# Criando uma colisão invisível para o ponto de spawn
	var collision = CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()  # Ou use CircleShape2D se for o caso
	collision.shape.extents = Vector2(10, 10)  # Ajuste o tamanho conforme necessário
	
	spawn_area.add_child(collision)
	$inimigos.add_child(spawn_area)  # Adiciona o ponto de spawn diretamente no World_01

	# Conectando o sinal da área para detectar quando a aura entra nela
	print("Área de spawn criada na posição: " + str(position) + " chamada " + spawn_area.name)  # Debug

# Função chamada quando a aura entra em uma área de spawn de inimigo
func _on_aura_distance_trigger(area: Area2D) -> void:
	print("Aura entrou na área: " + area.name)  # Debug: Confirme que a área está sendo detectada
	if area.name.begins_with("EnemySpawnArea_"):  # Verifica pelo nome da área
		print("Aura_sapo_distancia entrou na área de spawn!")
		
		# Comparar posição com uma tolerância de distância
		for enemy_info in enemy_data:
			if area.position.distance_to(enemy_info["position"]) < 10:  # Usando uma tolerância de 10 pixels
				spawn_enemy(enemy_info)
				enemy_data.erase(enemy_info)  # Remove da lista para evitar recriação duplicada
				break

func spawn_enemy(enemy_info: Dictionary):
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.position = enemy_info["position"]
	enemy_instance.name = enemy_info["name"]
	enemy_instance.CHASE_SPEED = enemy_info["chase_speed"]
	enemy_instance.SPEED = 100.0
	enemy_instance.direction = -1
	enemy_instance.is_chasing = enemy_info["is_chasing"]
	enemy_instance.area = enemy_info["area"]

	# Remover o spawn box antigo associado a este inimigo, se existir
	for child in $inimigos.get_children():
		if child.name == "EnemySpawnArea_" + str(enemy_instance.position):
			$inimigos.remove_child(child)
			child.queue_free()
			print("Área de detecção antiga removida para inimigo: " + enemy_instance.name)

	# Adicionar o novo inimigo ao nó `$inimigos`, necessário para trazer o nó criado para a cena
	$inimigos.add_child(enemy_instance)
	print("Inimigo recriado: " + enemy_instance.name)

	# Atribuir inimigo à sua área original
	for area in $"Áreas".get_children():
		if area.name == enemy_instance.area.name:
			area.add_enemy(enemy_instance)  # Associa o inimigo à área encontrada
			if area.overlaps_area(aura_prox_area):
				#print("SOBREPÔÔÔÔS")
				enemy_instance.start_chasing()
			break

	print("Inimigo recriado e configurado: " + enemy_instance.name)

	# Verificar e exibir os inimigos e áreas presentes em `$inimigos` para garantir que não há duplicatas
	for ini in $inimigos.get_children():
		print("inimigo: " + ini.name)

func iniciando_vidas_e_ataques() -> void:
	# Conectando o sinal de cada vida ao método que atualiza seu contador
	for vidas in $vidas.get_children():  # Todas vidas estão no Node2D 'vidas'
		vidas.connect("life_collected", Callable(self, "_on_life_collected"))
	# Conectando o sinal de cada ataque ao método que atualiza seu contador
	for ataque in $ataques.get_children():  # Todos ataques estão no Node2D 'ataques'
		ataque.connect("attack_collected", Callable(self, "_on_attack_collected"))
		print("sinal de ataque conectado") 

func _on_life_collected():
	medkits += 1
	print("vidas coletadas " + str(medkits))
	$HUD/container_vida/Controle2/contador_vidas.text = " x " + str(medkits)

func _on_attack_collected():
	attacks += 1
	print("ataques coletado " + str(attacks))
	$HUD/container_ataque/Controle2/contador_ataques.text = " x " + str(attacks)

func iniciando_comando_cura() -> void:
	if medkits > 0:
		player.vida += 1
		medkits -= 1
		$HUD/container_vida/Controle2/contador_vidas.text = " x " + str(medkits)
		$HUD/container_vida_persongem/Controle2/contador_coracoes.text = " x " + str(player.vida)
func damage_received() -> void:
		$HUD/container_vida_persongem/Controle2/contador_coracoes.text = " x " + str(player.vida)
		

func iniciando_comando_ataque() -> void:
	if attacks > 0:
		player.play_attack_animation()
		attacks -= 1
		$HUD/container_ataque/Controle2/contador_ataques.text = " x " + str(attacks)
