extends StateMachine
class_name BossStateMachine

signal phase_changed(number)

export(int, 1, 3) var phases = 1

var sequence_cycles = 0
var current_phase = 1

func _ready():
	for child in get_children():
		child.connect("finished", self, "go_to_next_state")

func initialize():
	change_phase(current_phase)
	
func _on_active_state_finished():
	go_to_next_state()

func go_to_next_state(state_override=null):
	if not active:
		return
	current_state.exit()
	current_state = _decide_on_next_state() if state_override == null else state_override
	emit_signal("state_changed", current_state)
	current_state.enter()

# Implemented in inheriting state machines
func _decide_on_next_state():
	pass
	
func change_phase(new_phase):
	current_phase = new_phase
	emit_signal("phase_changed", new_phase)

func _on_Stats_no_health():
	go_to_next_state($Die)
