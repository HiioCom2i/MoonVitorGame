extends Node2D


var lifes_collected = 1     # usados para recuperar corações
var attacks_collected = 2   # usado para atacar
var player_hearts = 5       # a vida do jogador, 
							# ficou meio confuso os nomes do recurso de
							# recuperar vida e a vida, mas paciência

func _ready():
	# Conectando o sinal de cada vida ao método que atualiza seu contador
	for vidas in $vidas.get_children():  # Todas vidas estão no Node2D 'vidas'
		vidas.connect("life_collected", Callable(self, "_on_life_collected"))
	# Conectando o sinal de cada ataque ao método que atualiza seu contador
	for ataque in $ataques.get_children():  # Todos ataques estão no Node2D 'ataques'
		ataque.connect("attack_collected", Callable(self, "_on_attack_collected"))
		print("sinal de ataque conectado")
		
func _on_life_collected():
	lifes_collected += 1
	print("vidas coletadas " + str(lifes_collected))
	$HUD/container_vida/Controle2/contador_vidas.text = " x " + str(lifes_collected)

func _on_attack_collected():
	attacks_collected += 1
	print("ataques coletado " + str(attacks_collected))
	$HUD/container_ataque/Controle2/contador_ataques.text = " x " + str(attacks_collected)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
