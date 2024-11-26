# sequence_node.gd
extends BehaviorNode
class_name SequenceNode

var children: Array = []

func tick(agent) -> int:
	for child in children:
		var status = child.tick(agent)
		if status == Status.FAILURE:
			return Status.FAILURE
		elif status == Status.RUNNING:
			return Status.RUNNING
	return Status.SUCCESS
