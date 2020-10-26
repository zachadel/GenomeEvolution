extends Node
#is_viable will determine whether or not death in card table. 
#replicate in organism, look for a successful reproduction 

#TO DIE FAST: 
#delete genes using command console

#Declaring/initializing variables to keep track of: 
var tiles_traveled = 0
var resources_consumed = 0
var resources_converted = 0
var rounds_run = 0
var progeny_made = 0
var energy_value = 0
var times_energy_added = 0
var reproduction_times = 0
var dmg_genes_no_error = 0
var dmg_genes_error = 0
var breaks_join_no_error = 0
var breaks_join_error = 0
var breaks_cpyRepair_no_error = 0
var breaks_cpyRepair_error = 0
var tiles_copied_cpyRepair = 0
var genes_copied_cpyRepair = 0
var tiles_crctd_cpyRepair = 0
var breaks_repaired_collapseDuplicates = 0
var removed_collapseDuplicates = 0
var majorUpgrades = 0
var minorUpgrades = 0
var majorDowngrades = 0
var minorDowngrades = 0
var majorUpgrades_blankTiles_newGene = 0
var num_skills = 0
var skills_gained = 0
var skills_lost = 0
var maxVal_cat1 = 0
var maxVal_essential = 0
var maxVal_ate = 0
var maxVal_pseudo
#might have to have more, try and figure out how many gene categories there are. 
var finalVal_essential = 0
var finalVal_ate = 0
var finalVal_pseudo = 0
#same thing as the comment above. 
var max_transposon_tiles = 0
var current_transposon_tiles = 0
var max_blank_tiles = 0
var final_blank_tiles = 0
var finalVal_blank = 0
var death_reason
var pseudoGene = 0
var trimmedTiles = 0
var splitElm = 0
var numInversions = 0
var tilesInverted = 0

var current_classicTE = 0
var current_zigzagTE = 0
var current_assistTE = 0
var current_buddyTE = 0
var current_nestlerTE = 0
var current_commuterTE = 0
var current_buncherTE = 0
var current_jumperTE = 0

var max_classicTE = 0
var max_zigzagTE = 0
var max_assistTE = 0
var max_buddyTE = 0
var max_nestlerTE = 0
var max_commuterTE = 0
var max_buncherTE = 0
var max_jumperTE = 0
# replication, locomotion, helper, manipulation, sensing, component, construction, deconstruction, ate

var currentReplication = 0
var currentLocomotion = 0
var currentHelper = 0
var currentManipulation = 0
var currentSensing = 0
var currentComponent = 0
var currentConstruction = 0
var currentDeconstruction = 0
var currentAte = 0
var maxReplic = 0
var maxLocomo = 0
var maxHelp = 0
var maxManipul = 0
var maxSens = 0
var maxComponent = 0
var maxConstruc = 0
var maxDeconstruc = 0
var maxAte =0
var transposonFuse = 0

func get_currentRep():
	return currentReplication
func get_currentLoc():
	return currentLocomotion
func get_currentHelp():
	return currentHelper
func get_currentManip():
	return currentManipulation
func get_currentSens():
	return currentSensing
func get_currentComp():
	return currentComponent
func get_currentCon():
	return currentConstruction
func get_currentDeCon():
	return currentDeconstruction
func get_currentAte():
	return currentAte
func get_maxRep():
	return maxReplic
func get_maxLocomo():
	return maxLocomo
func get_maxHelp():
	return maxHelp
func get_maxManip():
	return maxManipul
func get_maxSens():
	return maxSens
func get_maxComp():
	return maxComponent
func get_maxCon():
	return maxConstruc
func get_maxDecon():
	return maxDeconstruc
func get_maxAte():
	return maxAte


func update_currentType(gene):
	if(gene == "Replication"):
		currentReplication += 1
	elif(gene == "Locomotion"):
		currentLocomotion += 1
	elif(gene == "Helper"):
		currentHelper += 1
	elif(gene == "Manipulation"):
		currentManipulation += 1
	elif(gene == "Sensing"):
		currentSensing += 1
	elif(gene == "Component"):
		currentComponent += 1
	elif(gene == "Construction"):
		currentConstruction += 1
	elif(gene == "Deconstruction"):
		currentDeconstruction += 1
	elif(gene == "ate"):
		currentAte += 1

func update_maxType():
	if(currentReplication > maxReplic):
		maxReplic = currentReplication
	if(currentLocomotion > maxLocomo):
		maxLocomo = currentLocomotion 
	if(currentHelper > maxHelp):
		maxHelp = currentHelper
	if(currentManipulation > maxManipul):
		maxManipul = currentManipulation
	if(currentSensing > maxSens):
		maxSens = currentSensing
	if(currentComponent > maxComponent):
		maxComponent = currentComponent
	if(currentConstruction > maxConstruc):
		maxConstruc = currentConstruction
	if(currentDeconstruction > maxDeconstruc):
		maxDeconstruc = currentDeconstruction
	if(currentAte > maxAte):
		maxAte = currentAte


func increment_transposonFuse():
	transposonFuse += 1

func compare_maxTE():
	if(current_classicTE > max_classicTE):
		max_classicTE = current_classicTE
	if(current_zigzagTE > max_zigzagTE):
		max_zigzagTE = current_zigzagTE
	if(current_assistTE > max_assistTE):
		max_assistTE = current_assistTE
	if(current_buddyTE > max_buddyTE):
		max_buddyTE = current_buddyTE
	if(current_nestlerTE > max_nestlerTE):
		max_nestlerTE = current_nestlerTE
	if(current_commuterTE > max_commuterTE):
		max_commuterTE = current_commuterTE
	if(current_buncherTE > max_buncherTE):
		max_buncherTE = current_buncherTE
	if(max_jumperTE > current_jumperTE):
		max_jumperTE = current_jumperTE

func clear_currentTE():
	current_assistTE = 0
	current_buddyTE = 0
	current_buncherTE = 0
	current_classicTE = 0
	current_commuterTE = 0
	current_jumperTE = 0
	current_nestlerTE = 0
	current_zigzagTE = 0
#card, superjump, closefar, budding, cnearjfar, commuter, zigzag, buncher\n
func update_currentTE(TE):
	if(TE == "zigzag"):#
		current_zigzagTE += 1
	elif(TE =="card"): #
		current_classicTE += 1
	elif(TE == "superjump"): #
		current_jumperTE += 1
	elif(TE == "budding"): #
		current_buddyTE += 1
	elif(TE == "commmuter"): #
		current_commuterTE +=1
	elif(TE == "buncher"):# 
		current_buncherTE += 1
	elif(TE == "closefar"):
		current_assistTE += 1
	elif(TE == "cnearjfar"):
		current_nestlerTE += 1 

func increment_tilesInverted():
	tilesInverted += 1
func increment_numInversions():
	numInversions += 1

func increment_elmSplits():
	splitElm += 1

func increment_trimmedTiles():
	trimmedTiles +=1

func increment_total_pseduo():
	pseudoGene += 1

func maxBlankTiles():
	if(max_blank_tiles < final_blank_tiles):
		max_blank_tiles = final_blank_tiles

func compare_maxTransposon(TE):
	if(TE > max_transposon_tiles):
		max_transposon_tiles = TE

func set_currentTransposon(TE):
	current_transposon_tiles = TE

func set_reason_death(reason):
	death_reason = reason

func increment_final_blank_tiles():
	final_blank_tiles += 1

#What:Track the final number of blank tiles at game end
#Where: 
func get_final_blank_tiles():
	return final_blank_tiles

#What:Track the final number of blank tiles at game end
#Where: 
func set_final_blank_tiles(tiles):
	final_blank_tiles = tiles

#What: Track the maximum number of blank tiles
#Where: 
func get_max_blank_tiles():
	return max_blank_tiles

#What: Track the maximum number of blank tiles
#Where: 
func increment_max_blank_tiles():
	max_blank_tiles += 1

#What:Track the final number of transposon tiles at game end
#Where: transposon ui, in the setter function.
func get_final_transposon_tiles():
	return current_transposon_tiles
	
#What:Track the final number of transposon tiles at game end
#Where: 
func increment_final_transposon_tiles():
	current_transposon_tiles += 1
	
#What:Track the maximum number of transposon tiles
#Where: 
func get_max_transposon_tiles():
	return max_transposon_tiles

#What:Track the maximum number of transposon tiles
#Where: 
func increment_max_transposon_tiles():
	max_transposon_tiles += 1


#What: Track the final value earned for each gene category end
#Where: 
func get_finalVal_blank():
	return finalVal_blank

#What: Track the final value earned for each gene category end
#Where: 
func set_finalVal_blank(val):
	finalVal_blank = val

#What: Track the final value earned for each gene category end
#Where: 
func get_finalVal_essential():
	return finalVal_essential

#What: Track the final value earned for each gene category end
#Where: 
func set_finalVal_essential(val):
	finalVal_essential = val

#What: Track the final value earned for each gene category end
#Where: 
func get_finalVal_ate():
	return finalVal_ate

#What: Track the final value earned for each gene category end
#Where: 
func set_finalVal_ate(val):
	finalVal_ate = val 

#What: Track the final value earned for each gene category end
#Where: 
func get_finalVal_pseudo():
	return finalVal_pseudo

#What: Track the final value earned for each gene category end
#Where: 
func set_finalVal_pseudo(val):
	finalVal_pseudo = val 

#What:Track the maximum value earned by each gene category
#Where: 
func get_maxVal_cat1():
	return maxVal_cat1

#What:Track the maximum value earned by each gene category
#Where: 
func increment_maxVal_cat1():
	maxVal_cat1 += 1

#What:Track the number of skills learned by genes
#Where: 
func get_num_skills():
	return num_skills

#What:Track the number of skills learned by genes
#Where: 
func increment_num_skills():
	num_skills += 1
	skills_gained +=1

func decrement_num_sklls():
	num_skills -= 1
	skills_lost +=1
#What:Track the number of major upgrades received by blank tiles, resulting in a new gene
#Where: 
func get_majorUpgrades_blankTiles_newGene():
	return majorUpgrades_blankTiles_newGene

#What:Track the number of major upgrades received by blank tiles, resulting in a new gene
#Where: SequenceElement in evolve major
func increment_majorUpgrades_blankTiles_newGame():
	majorUpgrades_blankTiles_newGene += 1

#What:   Track the number of minor downgrades received by genes
#Where: 
func get_minorDowngrades():
	return minorDowngrades

#What:   Track the number of minor downgrades received by genes
#Where: 
func increment_minorDowngrades():
	minorDowngrades += 1

#What: Track the number of major downgrades received by genes
#Where: 
func get_majorDowngrades():
	return majorDowngrades

#What:  Track the number of major downgrades received by genes
#Where: 
func increment_majorDowngrades():
	majorDowngrades += 1

#What: Track the number of minor upgrades received by genes
#Where: 
func get_minorUpgrades():
	return minorUpgrades

#What: Track the number of minor upgrades received by genes
#Where: 
func increment_minorUpgrades():
	minorUpgrades += 1

#What Track the number of major upgrades received by genes

#where
func get_majorUpgrades():
	return majorUpgrades

#What:Track the number of major upgrades received by genes
#Where: 
func increment_majorUpgrades():
	majorUpgrades += 1

#what: Track number of tiles removed using collapse duplicates function
#where:
func get_removed_collapseDuplicates():
	return removed_collapseDuplicates

#what: Track number of tiles removed using collapse duplicates function
#where:
func increment_removed_collapseDuplicates():
	removed_collapseDuplicates += 1

#what: Track number of breaks repaired using collapse duplicates function
#where:
func get_break_repaired_collapseDuplicates():
	return breaks_repaired_collapseDuplicates

#what: Track number of breaks repaired using collapse duplicates function
#where:
func increment_break_repaired_collapseDuplicates():
	breaks_repaired_collapseDuplicates += 1

#What:Track number of tile corrected during copy repair
#Where:
func get_tiles_crctd_cpyRepair():
	return tiles_crctd_cpyRepair

#What: Track number of tile corrected during copy repair
#where:
func increment_tiles_crctd_cpyRepair():
	tiles_crctd_cpyRepair += 1

#What:  Track number of genes copied using the copy-repair function
#Where:
func get_genes_copied_cpyRepair():
	return genes_copied_cpyRepair

#What: Track number of genes copied using the copy-repair function
#Where: in repair_gene of organism, copy Pattern switch case 1-3.
func increment_genes_copied_cpyRepair():
	genes_copied_cpyRepair += 1

#What:   Track number of tiles copied using the copy-repair function
#Where: 
func get_tiles_copied_cpyRepair():
	return tiles_copied_cpyRepair

#What:   Track number of tiles copied using the copy-repair function
#Where:  in repair_gene of organism, copy Pattern switch case 1-3.
func increment_tiles_copied_cpyRepair():
	tiles_copied_cpyRepair += 1

#What:   Track number of breaks repaired using copy repair with errors
#where:
func get_breaks_cpyRepair_error():
	return breaks_cpyRepair_error

#What:   Track number of breaks repaired using copy repair with errors
#where: in repair_gene of organism, copy Pattern switch case 1-3.
func increment_breaks_cpyRepair_error():
	breaks_cpyRepair_error += 1

#What:Track number of breaks repaired using copy-repair with no errors
#where:
func get_breaks_cpyRepair_no_error():
	return breaks_cpyRepair_no_error

#What:Track number of breaks repaired using copy-repair with no errors
#where: in repair_gene of organism, copy Pattern switch case zero.
func increment_breaks_cpyRepair_no_error():
	breaks_cpyRepair_no_error += 1

#What:Track number of breaks repaired using join ends with errors
#where:
func get_breaks_join_error():
	return breaks_join_error
	
#What:Track number of breaks repaired using join ends with errors
#where:in repair_gap, in organism
func increment_breaks_join_error():
	breaks_join_error += 1
 
#What: Track number of breaks repaired using join ends with no errors
#where: 
func get_breaks_join():
	return breaks_join_no_error
	
#What: Track number of breaks repaired using join ends with no errors
#where:in repair_gap, in organism
func increment_breaks_join():
	breaks_join_no_error += 1

#What:Track number of damaged genes repaired using fix damaged genes with errors
#where:
func get_dmg_genes_error():
	return dmg_genes_error

#What:Track number of damaged genes repaired using fix damaged genes with errors
#where:in repair_gap, in organism
func increment_dmg_genes_error():
	 dmg_genes_error += 1

#What:Track number of damaged genes repaired using fix damaged genes with no errors
#where:
func get_dmg_genes_no_error():
	return dmg_genes_no_error

#What:Track number of damaged genes repaired using fix damaged genes with no errors
#where:in repair_gap, in organism
func increment_dmg_genes_no_error():
	dmg_genes_no_error += 1 

#What: Returns the number of times that reproduction is called.
#where: 
func get_reproduction_times():
	return reproduction_times

#What: increments the number of times that reproduction is done. 
#Where: Organism, in replicate function 
func increment_reproduction_times():
	reproduction_times += 1

#What: to show how many times a player will update from food to energy
#Where: EnergyBar in add_energy
func increment_times_energy_added():
	times_energy_added += 1

#What: returns the tiles traveled value
#where: 
func get_tiles_traveled():
	return tiles_traveled

#What: Increments the tiles traveled variable
#Where: WorldMap, within the move_player function
func increment_tiles_traveled(moved):
	tiles_traveled += moved

#What: returns the resources consumed
#where: 
func get_resources_consumed():
	return resources_consumed

#What: increments the resouces consumed variable
#where: In Organism, function: add_resource
func increment_resources_consumed():
	resources_consumed += 1
 
#What: returns the resources converted
#where: 
func get_resources_converted():
	return resources_converted

#What:Increments the number of times that the resources have been invcremented. 
#where: In organism, within the use_resource
func increment_resources_converted():
	resources_converted += 1

#What: returns the energy Value
#where: 
func get_Energy():
	return energy_value
#What: Sets the energy to the given value of the energy bar
#Where: EnergyBar.gd in update Energy Allocation

func set_Energy(energy):
	energy_value = energy

#What: returns the number of progeny in a game
#Where: pnl_dead_overview
func get_progeny():
	return progeny_made

#What: Increments progeny by 3 because of meiosis in replicate under Organism
#Where: Replicate() in Organism
func increment_progeny_meiosis():
	progeny_made += 3

#What: Increments progeny by 1 because of mitosis.
#Where: Replicate() in Organism
func increment_progeny_mitosis():
	progeny_made += 1

#what: returns RoundsRun
#Where: pnl_dead_overview
func get_rounds():
	return rounds_run

#What: Increments Rounds by 1
#Where: adv_turn in Card Table
func increment_Rounds():
	rounds_run += 1

# Called when the node enters the scene tree for the first time, not sure what to do with this guy
func _ready():
	pass # Replace with function body.
