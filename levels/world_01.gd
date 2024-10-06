extends Node2D


var lifes_collected = 0 

func _ready():
	# Suponha que você instanciou as moedas dinamicamente ou já tem elas na cena
	# Conecte o sinal de cada moeda ao método que atualiza o contador
	for vidas in $vidas.get_children():  # Suponha que as moedas estão no grupo "Coins"
		vidas.connect("life_collected", Callable(self, "_on_life_collected"))
		
func _on_life_collected():
	lifes_collected += 1
	print("moedas coletadas " + str(lifes_collected))
	$HUD/container_vida/Controle2/contador_vidas.text = " x " + str(lifes_collected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
