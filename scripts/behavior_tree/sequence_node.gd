# sequence_node.gd
extends BehaviorNode
class_name SequenceNode

var children: Array = []

func _init(child_nodes: Array):
	children = child_nodes

func tick(agent) -> int:
	for child in children:
		var status = child.tick(agent)
		if status == Status.FAILURE:
			return Status.FAILURE
		elif status == Status.RUNNING:
			return Status.RUNNING
	return Status.SUCCESS
