extends Node

export (PackedScene) var Gene

enum GAME_STATE{
	start,
	gainTE,
	jumpingTE,
	repairBreaks,
	environmentBreaks,
	repairEnvBreaks,
	recombination,
	evolve	
}

var game_state = GAME_STATE.start
var has_changed = true
var game_over = false
var score = 0

func _ready():
	game_over = false
	$score_text.text = "Score: " + str(score)
	game_state = GAME_STATE.gainTE
	$phase.text = str(game_state)

func _process(delta):
	if has_changed:
		match game_state:
			gainTE:
				$phase.text = str(game_state)
				game_state = GAME_STATE.jumpingTE
				pass
			jumpingTE:
				$phase.text = str(game_state)
				game_state = GAME_STATE.repairBreaks
				pass
			repairBreaks:
				$phase.text = str(game_state)
				game_state = GAME_STATE.environmentBreaks
				pass
			environmentBreaks:
				$phase.text = str(game_state)
				game_state = GAME_STATE.repairEnvBreaks
				pass
			repairEnvBreaks:
				$phase.text = str(game_state)
				game_state = GAME_STATE.recombination
				pass
			recombination:
				$phase.text = str(game_state)
				game_state = GAME_STATE.evolve
				pass
			evolve:
				$phase.text = str(game_state)
				pass
		has_changed = false
			
func _on_next_phase_button_down():
	has_changed = true
		
func scoring():
	pass
	
func turn_sequence():
	gain_transposons()
	transposon_jumping()
	
func gain_transposons():
	$chromosome.add_TE()
	
	
func transposon_jumping():
	pass
