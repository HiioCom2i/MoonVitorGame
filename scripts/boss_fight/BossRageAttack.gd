class_name BossRageAttack
extends GOAPAction

var boss: Node
var player: Node
var damage: float# mais dano que o ataque da estrela (que é 2)
var rage_cooldown_timer: Timer = null
var action_name = "BossRageAttack"

func _init(_boss, _player):
	boss = _boss
	player = _player
	print("BossRageAttack criado com player:", player)
	rage_cooldown_timer = Timer.new()
	rage_cooldown_timer.wait_time = 10.0 # exemplo de cooldown
	rage_cooldown_timer.one_shot = true
	rage_cooldown_timer.connect("timeout", Callable(self, "_on_rage_cooldown_timeout"))
	boss.add_child(rage_cooldown_timer)
	cost = - damage
	preconditions = {"enraged": true}
	effects = {"attack": true}
	
func apply(state: Dictionary) -> Dictionary:
	print("entrou no aplly do rage")
	var new_state = state.duplicate()
	new_state["attack"] = true
	return new_state

func execute():
	print("Boss tá enfurecido e atacando com fúria!")
	boss.is_rage_attack_on_cooldown = true
	boss.start_rage_attack(player)
	rage_cooldown_timer.start()

func _on_rage_cooldown_timeout():
	boss.is_rage_attack_on_cooldown = false
	print("Ataque de fúria pronto para ser usado novamente")

func reset():
	boss.is_rage_attack_on_cooldown = false
