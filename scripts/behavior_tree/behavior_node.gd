# behavior_node.gd CLASSE MÃE
extends Object
class_name BehaviorNode

enum Status { SUCCESS, FAILURE, RUNNING }

# Método a ser implementado pelas subclasses
func tick(agent) -> int:
	return Status.FAILURE
