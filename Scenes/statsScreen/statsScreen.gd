extends Panel
signal show_cardTable

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var has_updated_values = false
var turns_taken = 0;
var resources_consumed= 0;
var num_progeny= 0;
var tiles_explored= 0;

var current_replication_value = 0
var current_locomotion_value= 0
var current_helper_value= 0
var current_manipulation_value= 0
var current_sensing_value= 0
var current_component_value= 0
var current_construction_value= 0
var current_deconstruction_value= 0
var current_ate_value= 0
var current_blank_value =0
var current_pseudo_value =0

var max_replication_value =0
var max_locomotion_value=0
var max_helper_value=0
var max_manipulation_value=0
var max_sensing_value=0
var max_component_value =0
var max_construction_value =0
var max_deconstruction_value =0
var max_ate_value = 0
var max_blank_value = 0
var max_pseudo_value =0

var first_replication_value =0
var first_locomotion_value = 0
var first_helper_value = 0
var first_manipulation_value = 0
var first_sensing_value=0
var first_component_value =0
var first_construction_value = 0
var first_deconstruction_value =0
var first_ate_value=0
var first_blank_value =0
var first_pseudo_value =0


var maxBarGene1Size= 1
var maxBarGene2Size= 0
var maxBarGene3Size= 0
var maxBarGene4Size= 0
var maxBarGene5Size= 0
var maxBarGene6Size= 0
var maxBarGene7Size= 0
var maxBarGene8Size= 0
var maxBarGene9Size= 0

var currentBarGene1Size= 1
var currentBarGene2Size= 0
var currentBarGene3Size= 0
var currentBarGene4Size= 0
var currentBarGene5Size= 0
var currentBarGene6Size= 0
var currentBarGene7Size= 0
var currentBarGene8Size= 0
var currentBarGene9Size= 0

var maxBarGene1Pos= 0
var maxBarGene2Pos= 0
var maxBarGene3Pos= 0
var maxBarGene4Pos= 0
var maxBarGene5Pos= 0
var maxBarGene6Pos= 0
var maxBarGene7Pos= 0
var maxBarGene8Pos= 0
var maxBarGene9Pos= 0

var currentBarGene1Pos= 0
var currentBarGene2Pos= 0
var currentBarGene3Pos= 0
var currentBarGene4Pos= 0
var currentBarGene5Pos= 0
var currentBarGene6Pos= 0
var currentBarGene7Pos= 0
var currentBarGene8Pos= 0
var currentBarGene9Pos= 0

#current transposons
var current_classicTE = 0
var current_zigzagTE = 0
var current_assistTE = 0
var current_buddyTE = 0
var current_nestlerTE = 0
var current_commuterTE = 0
var current_buncherTE = 0
var current_jumperTE = 0

#max transposons
var max_classicTE = 0
var max_zigzagTE = 0
var max_assistTE = 0
var max_buddyTE = 0
var max_nestlerTE = 0
var max_commuterTE = 0
var max_buncherTE = 0
var max_jumperTE = 0

#Repairs
var dmgGeneRepairPerfect= 0
var dmgGeneRepairError= 0
var trimmedBreakEnds= 0
var breaksRepairedJoinEndsPerfect= 0
var breaksRepairedJoinEndsError= 0
var breaksRepairedCopyRepairPerfect= 0
var breaksRepairedCopyRepairError= 0
var tilesCopiedGenes= 0
var tilesCopiedTotal= 0
var tilesCorrectedCopyRepair= 0
var breaksRepairedCollapseDupes= 0
var tilesRemovedCollapseDupes= 0

#Evolution
var majorUp= 0
var majorDown= 0
var minorUp= 0
var minorDown= 0
var upInNewGene= 0
var downInPseudo= 0
var skillsGained= 0
var skillLost= 0
var TeFuse= 0
var geneSplit= 0



func _set_current_bar():
	#current_replication_value = 0;
	var currentBarSize = 1 + current_pseudo_value + current_blank_value + current_replication_value + current_locomotion_value + current_helper_value + current_manipulation_value + current_sensing_value + current_component_value + current_construction_value + current_deconstruction_value + current_ate_value;
	var current_CompositionBar = current_replication_value + current_locomotion_value + current_helper_value + current_manipulation_value + current_sensing_value + current_component_value + current_construction_value + current_deconstruction_value
	var thisSize = 550 - 50;
	#S$Label.text = str(currentBarSize)
	currentBarGene1Size = thisSize * current_CompositionBar/ currentBarSize;
	currentBarGene2Size = thisSize * current_pseudo_value / currentBarSize;
	currentBarGene3Size = thisSize * current_blank_value / currentBarSize;
	currentBarGene4Size = thisSize * current_ate_value / currentBarSize;

	
	currentBarGene1Pos = 10;
	currentBarGene2Pos = 10 + currentBarGene1Size + currentBarGene1Pos;
	currentBarGene3Pos = 10 + currentBarGene2Size + currentBarGene2Pos;
	currentBarGene4Pos = 10 + currentBarGene3Size + currentBarGene3Pos;

	
	$sub1/currentBar/currComposition.rect_position.x = currentBarGene1Pos
	$sub1/currentBar/currComposition.rect_size.x = currentBarGene1Size
	
	$sub1/currentBar/currPseudo.rect_position.x = currentBarGene2Pos
	$sub1/currentBar/currPseudo.rect_size.x = currentBarGene2Size
	
	$sub1/currentBar/currBlank.rect_position.x = currentBarGene3Pos
	$sub1/currentBar/currBlank.rect_size.x = currentBarGene3Size
	
	$sub1/currentBar/currTransposon.rect_position.x = currentBarGene4Pos
	$sub1/currentBar/currTransposon.rect_size.x = currentBarGene4Size
	
	$currBarDisplay/Label.text = "This is the current value of genes you had in your chromosome: "+str(current_CompositionBar)
	$currBarDisplay2/Label.text = "This is the current value of pseudogenes you had in your chromosome: "+str(current_pseudo_value)
	$currBarDisplay3/Label.text = "This is the current value of blank genes you had in your chromosome: " + str(current_blank_value)
	$currBarDisplay4/Label.text = "This is the current value of transposons you had in your chromosome: " + str(current_ate_value)
	
	pass

func _set_max_bar():
	#Setting values
	# The total length is of 490.
	# Here, we are setting up the bars porportionally.
	first_replication_value = STATS.get_first_replication();
	first_locomotion_value = STATS.get_first_locomotion();
	first_helper_value = STATS.get_first_helper();
	first_manipulation_value = STATS.get_first_manipulation();
	first_construction_value = STATS.get_first_construction();
	first_deconstruction_value = STATS.get_first_deconstruction();
	first_component_value = STATS.get_first_component();
	first_sensing_value = STATS.get_first_sensing();
	first_pseudo_value = STATS.get_first_pseudo();
	first_ate_value = STATS.get_first_ate();
	first_blank_value = STATS.get_first_blank();
	
	var maxBarSize = 1 + first_pseudo_value + first_blank_value + first_replication_value + first_locomotion_value + first_helper_value + first_manipulation_value + first_sensing_value + first_component_value + first_construction_value + first_deconstruction_value + first_ate_value;
	var first_compositionBar = STATS.get_first_sum()
	
	var thisSize = 550 - 50
	
	maxBarGene1Size = thisSize * first_compositionBar / maxBarSize;
	maxBarGene2Size = thisSize * first_pseudo_value / maxBarSize;
	maxBarGene3Size = thisSize * first_blank_value / maxBarSize;
	maxBarGene4Size = thisSize * first_ate_value / maxBarSize;
	
	maxBarGene1Pos = 10;
	maxBarGene2Pos = 10 + maxBarGene1Size + maxBarGene1Pos;
	maxBarGene3Pos = 10 + maxBarGene2Size + maxBarGene2Pos;
	maxBarGene4Pos = 10 + maxBarGene3Size + maxBarGene3Pos;
	maxBarGene5Pos = 10 + maxBarGene4Size + maxBarGene4Pos;
	
	$sub1/maxBar/maxComposition.rect_position.x = maxBarGene1Pos
	$sub1/maxBar/maxComposition.rect_size.x = maxBarGene1Size
	
	$sub1/maxBar/maxPseudo.rect_position.x = maxBarGene2Pos
	$sub1/maxBar/maxPseudo.rect_size.x = maxBarGene2Size
	
	$sub1/maxBar/maxBlank.rect_position.x = maxBarGene3Pos
	$sub1/maxBar/maxBlank.rect_size.x = maxBarGene3Size
	
	$sub1/maxBar/maxTransposons.rect_position.x = maxBarGene4Pos
	$sub1/maxBar/maxTransposons.rect_size.x = maxBarGene4Size
	
	$sub1/maxBar/score/score_txt.text= str(maxBarSize-1);
	$maxBarDisplay/Label.text = "This is the value of genes you had in your first chromosome: "+str(first_compositionBar)
	$maxBarDisplay2/Label.text= "This is the value of pseudogenes you had in your first chromosome: "+str(first_pseudo_value)
	$maxBarDisplay3/Label.text = "This is the value of blank genes you had in your first chromosome: "+str(first_blank_value)
	$maxBarDisplay4/Label.text="This is the value of transposons you had in your first chromosome: "+str(first_ate_value)

func _update_values():
	num_progeny = STATS.get_progeny();
	tiles_explored = STATS.get_tiles_traveled();
	resources_consumed = STATS.get_resources_consumed();
	turns_taken = STATS.get_rounds();
	#print("turns taken: "+ str(turns_taken))
	if(turns_taken > 0):
		has_updated_values = true;
	else:
		has_updated_values = false;
	
	#setting values for the current bar's value.
	current_replication_value = STATS.get_currentRep();
	current_locomotion_value = STATS.get_currentLoc();
	current_helper_value = STATS.get_currentHelp();
	current_manipulation_value = STATS.get_currentManip();
	current_sensing_value = STATS.get_currentSens();
	current_component_value = STATS.get_currentComp();
	current_construction_value = STATS.get_currentCon();
	current_deconstruction_value = STATS.get_currentDeCon();
	current_ate_value = STATS.get_currentAte();
	current_blank_value = STATS.get_currentBlank()
	current_pseudo_value = STATS.get_current_pseudo()
	
	if(turns_taken < 1):
		first_replication_value = current_replication_value;
		first_locomotion_value = current_locomotion_value;
		first_helper_value = current_helper_value;
		first_manipulation_value = current_manipulation_value;
		first_sensing_value = current_sensing_value;
		first_component_value = current_component_value;
		first_construction_value = current_construction_value;
		first_deconstruction_value = current_deconstruction_value;
		first_ate_value = current_ate_value;
		first_blank_value = current_blank_value;
		first_pseudo_value = current_pseudo_value;
	
	#setting values for the max bar's values. 
	max_replication_value = STATS.get_maxRep();
	max_locomotion_value = STATS.get_maxLocomo()
	max_helper_value = STATS.get_maxHelp();
	max_manipulation_value = STATS.get_maxManip();
	max_sensing_value = STATS.get_maxSens();
	max_component_value = STATS.get_maxComp();
	max_construction_value = STATS.get_maxCon();
	max_deconstruction_value = STATS.get_maxDecon();
	max_blank_value = STATS.get_max_blank_tiles()
	max_ate_value = STATS.get_maxAte();
	max_pseudo_value = STATS.get_maxVal_pseudo()
	
	# current transposons
	current_classicTE = STATS.get_current_classicTE()
	current_zigzagTE = STATS.get_current_zigzagTE()
	current_assistTE = STATS.get_current_assistTE()
	current_buddyTE = STATS.get_current_buddyTE()
	current_nestlerTE = STATS.get_current_nestlerTE()
	current_commuterTE = STATS.get_current_commuterTE()
	current_buncherTE = STATS.get_current_buncherTE()
	current_jumperTE = STATS.get_current_jumperTE()
	
	# max transposons

	max_classicTE = STATS.get_max_classicTE()
	max_zigzagTE = STATS.get_max_zigzagTE()
	max_assistTE = STATS.get_max_assistTE()
	max_buddyTE = STATS.get_max_buddyTE()
	max_nestlerTE = STATS.get_max_nestlerTE()
	max_commuterTE = STATS.get_max_commuterTE()
	max_buncherTE = STATS.get_max_buncherTE()
	max_jumperTE = STATS.get_max_jumperTE()
	if(max_jumperTE < current_jumperTE):
		max_jumperTE = current_jumperTE
	
	#Repairs
	dmgGeneRepairPerfect = STATS.get_dmg_genes_no_error();
	dmgGeneRepairError = STATS.get_dmg_genes_error();
	trimmedBreakEnds = STATS.get_trimmedTiles();
	breaksRepairedJoinEndsPerfect = STATS.get_breaks_join();
	breaksRepairedJoinEndsError = STATS.get_breaks_join_error();
	breaksRepairedCopyRepairPerfect = STATS.get_breaks_cpyRepair_no_error(); 
	breaksRepairedCopyRepairError = STATS.get_breaks_cpyRepair_error();
	tilesCopiedGenes= STATS.get_genes_copied_cpyRepair();
	tilesCopiedTotal= STATS.get_tiles_copied_cpyRepair();
	tilesCorrectedCopyRepair= STATS.get_tiles_crctd_cpyRepair();
	breaksRepairedCollapseDupes= STATS.get_break_repaired_collapseDuplicates();
	tilesRemovedCollapseDupes= STATS.get_removed_collapseDuplicates();
	
	#Evolution
	majorUp = STATS.get_majorUpgrades();
	majorDown = STATS.get_majorDowngrades();
	minorUp = STATS.get_minorUpgrades();
	minorDown = STATS.get_minorDowngrades();
	upInNewGene= STATS.get_majorUpgrades_blankTiles_newGene();
	downInPseudo= STATS.get_downToPseudo();
	skillsGained= STATS.get_skills_gained();
	skillLost= STATS.get_skills_lost();
	TeFuse = STATS.get_TEFuse();
	geneSplit = STATS.get_geneSplit();
	
func _set_transposons():
	#setting the colors
	$sub1/TE1/AnthroArt.set_color(Color.red)
	$sub1/TE2/AnthroArt2.set_color(Color.red)
	$sub1/TE3/AnthroArt3.set_color(Color.red)
	$sub1/TE4/AnthroArt4.set_color(Color.red)
	$sub1/TE5/AnthroArt5.set_color(Color.red)
	$sub1/TE6/AnthroArt6.set_color(Color.red)
	$sub1/TE7/AnthroArt7.set_color(Color.red)
	$sub1/TE8/AnthroArt8.set_color(Color.red)
	#setting the body types
	$sub1/TE1/AnthroArt/Art2D/Body/BodySprite.texture = load("res://Assets/Images/tes/circle_body.png")
	$sub1/TE2/AnthroArt2/Art2D/Body/BodySprite.texture = load("res://Assets/Images/tes/kite_body.png")
	$sub1/TE3/AnthroArt3/Art2D/Body/BodySprite.texture = load("res://Assets/Images/tes/hexagon_body.png")
	$sub1/TE4/AnthroArt4/Art2D/Body/BodySprite.texture = load("res://Assets/Images/tes/pentagon_body.png")
	$sub1/TE5/AnthroArt5/Art2D/Body/BodySprite.texture = load("res://Assets/Images/tes/star_body.png")
	$sub1/TE6/AnthroArt6/Art2D/Body/BodySprite.texture = load("res://Assets/Images/tes/semicircle_body.png")
	$sub1/TE6/AnthroArt6/Art2D/Body/BodySprite.flip_v = true
	$sub1/TE7/AnthroArt7/Art2D/Body/BodySprite.texture = load("res://Assets/Images/tes/square_body.png")
	$sub1/TE8/AnthroArt8/Art2D/Body/BodySprite.texture = load("res://Assets/Images/tes/triangle_body.png")
	
	#setting the values
	$sub1/TE1/currScore/Label.text = str(current_classicTE)
	$sub1/TE2/currScore/Label.text = str(current_zigzagTE)
	$sub1/TE3/currScore/Label.text = str(current_assistTE)
	$sub1/TE4/currScore/Label.text = str(current_buddyTE)
	$sub1/TE5/currScore/Label.text = str(current_nestlerTE)
	$sub1/TE6/currScore/Label.text = str(current_commuterTE)
	$sub1/TE7/currScore/Label.text = str(current_buncherTE)
	$sub1/TE8/currScore/Label.text = str(current_jumperTE)
	
	$sub1/TE1/maxScore/Label.text = str(max_classicTE)
	$sub1/TE2/maxScore/Label.text = str(max_zigzagTE)
	$sub1/TE3/maxScore/Label.text = str(max_assistTE)
	$sub1/TE4/maxScore/Label.text = str(max_buddyTE)
	$sub1/TE5/maxScore/Label.text = str(max_nestlerTE)
	$sub1/TE6/maxScore/Label.text = str(max_commuterTE)
	$sub1/TE7/maxScore/Label.text = str(max_buncherTE)
	if(max_jumperTE < current_jumperTE):
		max_jumperTE = current_jumperTE;
	$sub1/TE8/maxScore/Label.text = str(max_jumperTE)
func _set_values():
	#main values
	$mainStat1/score.text = str(turns_taken);
	$mainStat2/score.text = str(resources_consumed)
	$mainStat3/score.text = str(tiles_explored)
	$mainStat4/score.text = str(num_progeny)
	
	
	#Composition values
	var genesNumber = first_pseudo_value+ first_blank_value + first_replication_value + first_locomotion_value + first_helper_value + first_manipulation_value + first_sensing_value + first_component_value + first_construction_value + first_deconstruction_value + first_ate_value;
	var currentNumber = current_pseudo_value + current_blank_value + current_replication_value + current_locomotion_value + current_helper_value + current_manipulation_value + current_sensing_value + current_component_value + current_construction_value + current_deconstruction_value + current_ate_value;
	if(genesNumber <= currentNumber):
		genesNumber = currentNumber;
	$sub1/currentBar/currscore/score_txt.text = str(currentNumber) #should display the total number genes in the bar
	
	#current gene composition
	$sub1/gene1/currScore/currScoret.text = str(current_replication_value)
	$sub1/gene2/currScore/currScoret.text = str(current_sensing_value)
	$sub1/gene3/currScore/currScoret.text = str(current_manipulation_value)
	$sub1/gene4/currScore/currScoret.text = str(current_component_value)
	$sub1/gene5/currScore/currScoret.text = str(current_construction_value)
	$sub1/gene6/currScore/currScoret.text = str(current_deconstruction_value)
	$sub1/gene7/currScore/currScoret.text = str(current_helper_value)
	$sub1/gene8/currScore/currScoret.text = str(current_locomotion_value)
	
	if(current_replication_value == 0 and has_updated_values):
		$sub1/gene1/currScore.color = Color.red
	else:
		$sub1/gene1/currScore.color = Color.yellow
	if(current_sensing_value == 0 and has_updated_values):
		$sub1/gene2/currScore.color = Color.red
	else:
		$sub1/gene2/currScore.color = Color.yellow
	if(current_manipulation_value == 0 and has_updated_values):
		$sub1/gene3/currScore.color = Color.red
	else:
		$sub1/gene3/currScore.color = Color.yellow
	if(current_component_value== 0 and has_updated_values):
		$sub1/gene4/currScore.color = Color.red
	else:
		$sub1/gene4/currScore.color = Color.yellow
	if(current_construction_value== 0 and has_updated_values):
		$sub1/gene5/currScore.color = Color.red
	else:
		$sub1/gene5/currScore.color = Color.yellow
	if(current_deconstruction_value== 0 and has_updated_values):
		$sub1/gene6/currScore.color = Color.red
	else:
		$sub1/gene6/currScore.color = Color.yellow
	if(current_helper_value== 0 and has_updated_values):
		$sub1/gene7/currScore.color = Color.red
	else:
		$sub1/gene7/currScore.color = Color.yellow
	if(current_locomotion_value== 0 and has_updated_values):
		$sub1/gene8/currScore.color = Color.red
	else:
		$sub1/gene8/currScore.color = Color.yellow
	# max gene composition
	$sub1/gene1/maxScore/maxScoret.text = str(max_replication_value)
	$sub1/gene2/maxScore/maxScoret.text = str(max_sensing_value)
	$sub1/gene3/maxScore/maxScoret.text = str(max_manipulation_value)
	$sub1/gene4/maxScore/maxScoret.text = str(max_component_value)
	$sub1/gene5/maxScore/maxScoret.text = str(max_construction_value)
	$sub1/gene6/maxScore/maxScoret.text = str(max_deconstruction_value)
	$sub1/gene7/maxScore/maxScoret.text = str(max_helper_value)
	$sub1/gene8/maxScore/maxScoret.text = str(max_locomotion_value)
	# Repairs
	$sub2/rep1/rep1Score/score1Text.text = str(dmgGeneRepairPerfect)
	$sub2/rep1/rep1Score2/score2Text.text = str(dmgGeneRepairError)
	$sub2/rep2/rep1Score/score1Text.text = str(trimmedBreakEnds)
	$sub2/rep4/rep1Score/score1Text.text = str(breaksRepairedCopyRepairPerfect)
	$sub2/rep4/rep1Score2/score2Text.text = str(breaksRepairedCopyRepairError)
	$sub2/rep3/rep1Score/score1Text.text = str(breaksRepairedJoinEndsPerfect)
	$sub2/rep3/rep1Score2/score2Text.text = str(breaksRepairedJoinEndsError)
	$sub2/rep5/rep1Score/score1Text.text = str(tilesCopiedGenes)
	$sub2/rep5/rep1Score/score1Text.text = str(tilesCopiedTotal)
	$sub2/rep6/rep1Score/score1Text.text = str(tilesCorrectedCopyRepair)
	$sub2/rep7/rep1Score/score1Text.text = str(breaksRepairedCollapseDupes)
	$sub2/rep8/rep1Score/score1Text.text = str(tilesRemovedCollapseDupes)
	#Evolutions
	$sub3/ev1/rep1Score/score1Text.text = str(majorUp)
	$sub3/ev1/rep1Score2/score2Text.text = str(majorDown)
	$sub3/ev2/rep1Score/score1Text.text = str(minorUp)
	$sub3/ev2/rep1Score2/score2Text.text = str(minorDown)
	$sub3/ev3/rep1Score/score1Text.text = str(upInNewGene)
	$sub3/ev3/rep1Score2/score2Text.text = str(downInPseudo)
	$sub3/ev4/rep1Score/score1Text.text = str(skillsGained)
	$sub3/ev4/rep1Score2/score2Text.text = str(skillLost)
	$sub3/ev5/rep1Score/score1Text.text = str(TeFuse)
	$sub3/ev6/rep1Score/score1Text.text = str(geneSplit)

func _ready():
	#hide()
	_update_values()
	_set_transposons()
	_set_max_bar()
	_set_current_bar()
	_set_values()
	pass # Replace with function body.

func _reset_values():
	has_updated_values = false;
	#reset variables
	turns_taken = 0;
	resources_consumed= 0;
	num_progeny= 0;
	tiles_explored= 0;
	current_replication_value = 0
	current_locomotion_value= 0
	current_helper_value= 0
	current_manipulation_value= 0
	current_sensing_value= 0
	current_component_value= 0
	current_construction_value= 0
	current_deconstruction_value= 0
	current_ate_value= 0
	current_blank_value =0
	max_replication_value =0
	max_locomotion_value=0
	max_helper_value=0
	max_manipulation_value=0
	max_sensing_value=0
	max_component_value =0
	max_construction_value =0
	max_deconstruction_value =0
	max_ate_value = 0
	max_blank_value = 0
	maxBarGene1Size= 1
	maxBarGene2Size= 0
	maxBarGene3Size= 0
	maxBarGene4Size= 0
	maxBarGene5Size= 0
	maxBarGene6Size= 0
	maxBarGene7Size= 0
	maxBarGene8Size= 0
	maxBarGene9Size= 0
	currentBarGene1Size= 1
	currentBarGene2Size= 0
	currentBarGene3Size= 0
	currentBarGene4Size= 0
	currentBarGene5Size= 0
	currentBarGene6Size= 0
	currentBarGene7Size= 0
	currentBarGene8Size= 0
	currentBarGene9Size= 0
	maxBarGene1Pos= 0
	maxBarGene2Pos= 0
	maxBarGene3Pos= 0
	maxBarGene4Pos= 0
	maxBarGene5Pos= 0
	maxBarGene6Pos= 0
	maxBarGene7Pos= 0
	maxBarGene8Pos= 0
	maxBarGene9Pos= 0
	currentBarGene1Pos= 0
	currentBarGene2Pos= 0
	currentBarGene3Pos= 0
	currentBarGene4Pos= 0
	currentBarGene5Pos= 0
	currentBarGene6Pos= 0
	currentBarGene7Pos= 0
	currentBarGene8Pos= 0
	currentBarGene9Pos= 0
	current_classicTE = 0
	current_zigzagTE = 0
	current_assistTE = 0
	current_buddyTE = 0
	current_nestlerTE = 0
	current_commuterTE = 0
	current_buncherTE = 0
	current_jumperTE = 0
	max_classicTE = 0
	max_zigzagTE = 0
	max_assistTE = 0
	max_buddyTE = 0
	max_nestlerTE = 0
	max_commuterTE = 0
	max_buncherTE = 0
	max_jumperTE = 0
	dmgGeneRepairPerfect= 0
	dmgGeneRepairError= 0
	trimmedBreakEnds= 0
	breaksRepairedJoinEndsPerfect= 0
	breaksRepairedJoinEndsError= 0
	breaksRepairedCopyRepairPerfect= 0
	breaksRepairedCopyRepairError= 0
	tilesCopiedGenes= 0
	tilesCopiedTotal= 0
	tilesCorrectedCopyRepair= 0
	breaksRepairedCollapseDupes= 0
	tilesRemovedCollapseDupes= 0
	majorUp= 0
	majorDown= 0
	minorUp= 0
	minorDown= 0
	upInNewGene= 0
	downInPseudo= 0
	skillsGained= 0
	skillLost= 0
	TeFuse= 0
	geneSplit= 0
	_set_values()
	_set_max_bar()
	_set_current_bar()
	#reset display values
	#reset bars
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_mouse_entered():
	_update_values()
	$mainStat1/labelMaker/Label.show()

func _on_mouse_exited():
	_update_values()
	$mainStat1/labelMaker/Label.hide()

func _on_StatsScreen_pressed():
	#set values
	_update_values()
	_set_current_bar()
	_set_max_bar()
	_set_values()
	#update the bar
	#update the interface
	visible = true
	pass # Replace with function body.


func _on_stats_screen_pressed():
	#set values
	
	_update_values()
	_set_current_bar()
	_set_max_bar()
	_set_values()
	#update the interface
	#update the bar
	visible = true
	pass # Replace with function body.


func _on_back_pressed():
	visible = false
	emit_signal("show_cardTable")
	pass # Replace with function body.


func _on_mainStat1_mouse_entered():
	$dataDisplay.show();
	pass # Replace with function body.


func _on_mainStat1_mouse_exited():
	$dataDisplay.hide()
	pass # Replace with function body.


func _on_mainStat2_mouse_entered():
	$dataDisplay2.show()
	pass # Replace with function body.


func _on_mainStat2_mouse_exited():
	$dataDisplay2.hide()
	pass # Replace with function body.


func _on_mainStat3_mouse_entered():
	$dataDisplay3.show()
	pass # Replace with function body.


func _on_mainStat3_mouse_exited():
	$dataDisplay3.hide()
	pass # Replace with function body.


func _on_mainStat4_mouse_entered():
	$dataDisplay4.show()
	pass # Replace with function body.


func _on_mainStat4_mouse_exited():
	$dataDisplay4.hide()
	pass # Replace with function body.


func _on_maxBar_mouse_entered():
	$dataDisplay5.show()
	pass # Replace with function body.


func _on_maxBar_mouse_exited():
	$dataDisplay5.hide()
	pass # Replace with function body.


func _on_currentBar_mouse_entered():
	$dataDisplay6.show()
	pass # Replace with function body.


func _on_currentBar_mouse_exited():
	$dataDisplay6.hide()
	pass # Replace with function body.


func _on_gene1_mouse_entered():
	$geneDisplay1.show()
	pass # Replace with function body.


func _on_gene1_mouse_exited():
	$geneDisplay1.hide()
	pass # Replace with function body.


func _on_gene2_mouse_entered():
	$geneDisplay2.show()
	pass # Replace with function body.


func _on_gene2_mouse_exited():
	$geneDisplay2.hide()
	pass # Replace with function body.


func _on_gene3_mouse_entered():
	$geneDisplay3.show()
	pass # Replace with function body.


func _on_gene3_mouse_exited():
	$geneDisplay3.hide()
	pass # Replace with function body.


func _on_gene4_mouse_entered():
	$geneDisplay4.show()
	pass # Replace with function body.


func _on_gene4_mouse_exited():
	$geneDisplay4.hide()
	pass # Replace with function body.


func _on_gene5_mouse_entered():
	$geneDisplay5.show()
	pass # Replace with function body.


func _on_gene5_mouse_exited():
	$geneDisplay5.hide()
	pass # Replace with function body.


func _on_gene6_mouse_entered():
	$geneDisplay6.show()
	pass # Replace with function body.


func _on_gene6_mouse_exited():
	$geneDisplay6.hide()
	pass # Replace with function body.


func _on_gene7_mouse_entered():
	$geneDisplay7.show()
	pass # Replace with function body.


func _on_gene7_mouse_exited():
	$geneDisplay7.hide()
	pass # Replace with function body.


func _on_transposon2_mouse_entered():
	$geneDisplay8.show()
	pass # Replace with function body.


func _on_transposon2_mouse_exited():
	$geneDisplay8.hide()
	pass # Replace with function body.


func _on_transposon3_mouse_entered():
	$geneDisplay9.show()
	pass # Replace with function body.


func _on_transposon3_mouse_exited():
	$geneDisplay9.hide()
	pass # Replace with function body.


func _on_transposon4_mouse_entered():
	$geneDisplay10.show()
	pass # Replace with function body.


func _on_transposon4_mouse_exited():
	$geneDisplay10.hide()
	pass # Replace with function body.


func _on_transposon5_mouse_entered():
	$geneDisplay11.show()
	pass # Replace with function body.


func _on_transposon5_mouse_exited():
	$geneDisplay11.hide()
	pass # Replace with function body.


func _on_transposon6_mouse_entered():
	$geneDisplay12.show()
	pass # Replace with function body.


func _on_transposon6_mouse_exited():
	$geneDisplay12.hide()
	pass # Replace with function body.


func _on_transposon7_mouse_entered():
	$geneDisplay13.show()
	pass # Replace with function body.


func _on_transposon7_mouse_exited():
	$geneDisplay13.hide()
	pass # Replace with function body.


func _on_rep1_mouse_entered():
	$repairDisplay1.show()
	pass # Replace with function body.


func _on_rep1_mouse_exited():
	$repairDisplay1.hide()
	pass # Replace with function body.


func _on_rep2_mouse_entered():
	$repairDisplay2.show()
	pass # Replace with function body.


func _on_rep2_mouse_exited():
	$repairDisplay2.hide()
	pass # Replace with function body.


func _on_rep3_mouse_entered():
	$repairDisplay3.show()
	pass # Replace with function body.


func _on_rep3_mouse_exited():
	$repairDisplay3.hide()
	pass # Replace with function body.


func _on_rep4_mouse_entered():
	$repairDisplay4.show()
	pass # Replace with function body.


func _on_rep4_mouse_exited():
	$repairDisplay4.hide()
	pass # Replace with function body.


func _on_rep5_mouse_entered():
	$repairDisplay5.show()
	pass # Replace with function body.


func _on_rep5_mouse_exited():
	$repairDisplay5.hide()
	pass # Replace with function body.


func _on_rep6_mouse_entered():
	$repairDisplay6.show()
	pass # Replace with function body.


func _on_rep6_mouse_exited():
	$repairDisplay6.hide()
	pass # Replace with function body.


func _on_rep7_mouse_entered():
	$repairDisplay7.show()
	pass # Replace with function body.


func _on_rep7_mouse_exited():
	$repairDisplay7.hide()
	pass # Replace with function body.


func _on_rep8_mouse_entered():
	$repairDisplay8.show()
	pass # Replace with function body.


func _on_rep8_mouse_exited():
	$repairDisplay8.hide()
	pass # Replace with function body.


func _on_rep9_mouse_entered():
	$repairDisplay9.show()
	pass # Replace with function body.


func _on_rep9_mouse_exited():
	$repairDisplay9.hide()
	pass # Replace with function body.


func _on_ev1_mouse_entered():
	$evDisplay1.show()
	pass # Replace with function body.


func _on_ev1_mouse_exited():
	$evDisplay1.hide()
	pass # Replace with function body.


func _on_ev2_mouse_entered():
	$evDisplay2.show()
	pass # Replace with function body.


func _on_ev2_mouse_exited():
	$evDisplay2.hide()
	pass # Replace with function body.


func _on_ev3_mouse_entered():
	$evDisplay3.show()
	pass # Replace with function body.


func _on_ev3_mouse_exited():
	$evDisplay3.hide()
	pass # Replace with function body.


func _on_ev4_mouse_entered():
	$evDisplay4.show()
	pass # Replace with function body.


func _on_ev4_mouse_exited():
	$evDisplay4.hide()
	pass # Replace with function body.


func _on_ev5_mouse_entered():
	$evDisplay5.show()
	pass # Replace with function body.


func _on_ev5_mouse_exited():
	$evDisplay5.hide()
	pass # Replace with function body.


func _on_ev6_mouse_entered():
	$evDisplay6.show()
	pass # Replace with function body.


func _on_ev6_mouse_exited():
	$evDisplay6.hide()
	pass # Replace with function body.


func _on_ev7_mouse_entered():
	$evDisplay7.show()
	pass # Replace with function body.


func _on_ev7_mouse_exited():
	$evDisplay7.hide()
	pass # Replace with function body.


func _on_AnthroArt_mouse_entered():
	$geneDisplay9.show()
	pass # Replace with function body.


func _on_AnthroArt_mouse_exited():
	$geneDisplay9.hide()
	pass # Replace with function body.


func _on_AnthroArt2_mouse_entered():
	$geneDisplay10.show()
	pass # Replace with function body.


func _on_AnthroArt2_mouse_exited():
	$geneDisplay10.hide()
	pass # Replace with function body.


func _on_AnthroArt3_mouse_entered():
	$geneDisplay11.show()
	pass # Replace with function body.


func _on_AnthroArt3_mouse_exited():
	$geneDisplay11.hide()
	pass # Replace with function body.


func _on_AnthroArt4_mouse_entered():
	$geneDisplay12.show()
	pass # Replace with function body.


func _on_AnthroArt4_mouse_exited():
	$geneDisplay12.hide()
	pass # Replace with function body.


func _on_AnthroArt5_mouse_entered():
	$geneDisplay13.show()
	pass # Replace with function body.


func _on_AnthroArt5_mouse_exited():
	$geneDisplay13.hide()
	pass # Replace with function body.


func _on_AnthroArt6_mouse_entered():
	$geneDisplay14.show()
	pass # Replace with function body.


func _on_AnthroArt6_mouse_exited():
	$geneDisplay14.hide()
	pass # Replace with function body.


func _on_AnthroArt7_mouse_entered():
	$geneDisplay15.show()
	pass # Replace with function body.


func _on_AnthroArt7_mouse_exited():
	$geneDisplay15.hide()
	pass # Replace with function body.


func _on_AnthroArt8_mouse_entered():
	$geneDisplay16.show()
	pass # Replace with function body.


func _on_AnthroArt8_mouse_exited():
	$geneDisplay16.hide()
	pass # Replace with function body.


func _on_gene8_mouse_entered():
	$geneDisplay8.show()
	pass # Replace with function body.


func _on_gene8_mouse_exited():
	$geneDisplay8.hide()
	pass # Replace with function body.


func _on_TE1_mouse_entered():
	$geneDisplay9.show()
	pass # Replace with function body.


func _on_TE1_mouse_exited():
	$geneDisplay9.hide()
	pass # Replace with function body.


func _on_TE2_mouse_entered():
	$geneDisplay10.show()
	pass # Replace with function body.


func _on_TE2_mouse_exited():
	$geneDisplay10.hide()
	pass # Replace with function body.


func _on_TE3_mouse_entered():
	$geneDisplay11.show()
	pass # Replace with function body.


func _on_TE3_mouse_exited():
	$geneDisplay11.hide()
	pass # Replace with function body.


func _on_TE4_mouse_entered():
	$geneDisplay12.show()
	pass # Replace with function body.


func _on_TE4_mouse_exited():
	$geneDisplay12.hide()
	pass # Replace with function body.


func _on_TE5_mouse_entered():
	$geneDisplay13.show()
	pass # Replace with function body.


func _on_TE5_mouse_exited():
	$geneDisplay13.hide()
	pass # Replace with function body.


func _on_TE6_mouse_exited():
	$geneDisplay14.hide()
	pass # Replace with function body.


func _on_TE6_mouse_entered():
	$geneDisplay14.show()
	pass # Replace with function body.


func _on_TE7_mouse_entered():
	$geneDisplay15.show()
	pass # Replace with function body.


func _on_TE7_mouse_exited():
	$geneDisplay15.hide()
	pass # Replace with function body.


func _on_TE8_mouse_entered():
	$geneDisplay16.show()
	pass # Replace with function body.


func _on_TE8_mouse_exited():
	$geneDisplay16.hide()
	pass # Replace with function body.


func _on_maxgene1_mouse_entered():
	$maxBarDisplay.show()
	pass # Replace with function body.


func _on_maxgene1_mouse_exited():
	$maxBarDisplay.hide()
	pass # Replace with function body.


func _on_maxgene2_mouse_entered():
	$maxBarDisplay2.show()
	pass # Replace with function body.


func _on_maxgene2_mouse_exited():
	$maxBarDisplay2.hide()
	pass # Replace with function body.


func _on_maxgene3_mouse_entered():
	$maxBarDisplay3.show()
	pass # Replace with function body.


func _on_maxgene3_mouse_exited():
	$maxBarDisplay3.hide()
	pass # Replace with function body.


func _on_maxgene4_mouse_entered():
	$maxBarDisplay4.show()
	pass # Replace with function body.


func _on_maxgene4_mouse_exited():
	$maxBarDisplay4.hide()
	pass # Replace with function body.


func _on_maxgene5_mouse_entered():
	$maxBarDisplay5.show()
	pass # Replace with function body.


func _on_maxgene5_mouse_exited():
	$maxBarDisplay5.hide()
	pass # Replace with function body.


func _on_maxgene6_mouse_entered():
	$maxBarDisplay6.show()
	pass # Replace with function body.


func _on_maxgene6_mouse_exited():
	$maxBarDisplay6.hide()
	pass # Replace with function body.


func _on_maxgene7_mouse_entered():
	$maxBarDisplay7.show()
	pass # Replace with function body.


func _on_maxgene7_mouse_exited():
	$maxBarDisplay7.hide()
	pass # Replace with function body.


func _on_maxgene8_mouse_entered():
	$maxBarDisplay8.show()
	pass # Replace with function body.


func _on_maxgene8_mouse_exited():
	$maxBarDisplay8.hide()
	pass # Replace with function body.


func _on_maxgene9_mouse_entered():
	$maxBarDisplay9.show()
	pass # Replace with function body.


func _on_maxgene9_mouse_exited():
	$maxBarDisplay9.hide()
	pass # Replace with function body.


func _on_score_mouse_entered():
	$dataDisplay5.show()
	pass # Replace with function body.


func _on_score_mouse_exited():
	$dataDisplay5.hide()
	pass # Replace with function body.


func _on_currscore_mouse_entered():
	$dataDisplay6.show()
	pass # Replace with function body.


func _on_currscore_mouse_exited():
	$dataDisplay6.hide()
	pass # Replace with function body.


func _on_currgene1_mouse_entered():
	$currBarDisplay.show()
	pass # Replace with function body.


func _on_currgene1_mouse_exited():
	$currBarDisplay.hide()
	pass # Replace with function body.


func _on_currgene2_mouse_entered():
	$currBarDisplay2.show()
	pass # Replace with function body.


func _on_currgene2_mouse_exited():
	$currBarDisplay2.hide()
	pass # Replace with function body.


func _on_currgene3_mouse_entered():
	$currBarDisplay3.show()
	pass # Replace with function body.


func _on_currgene3_mouse_exited():
	$currBarDisplay3.hide()
	pass # Replace with function body.


func _on_currgene4_mouse_entered():
	$currBarDisplay4.show()
	pass # Replace with function body.


func _on_currgene4_mouse_exited():
	$currBarDisplay4.hide()
	pass # Replace with function body.


func _on_currgene5_mouse_entered():
	$currBarDisplay5.show()
	pass # Replace with function body.


func _on_currgene5_mouse_exited():
	$currBarDisplay5.hide()
	pass # Replace with function body.


func _on_currgene6_mouse_entered():
	$currBarDisplay6.show()
	pass # Replace with function body.


func _on_currgene6_mouse_exited():
	$currBarDisplay6.hide()
	pass # Replace with function body.


func _on_currgene7_mouse_entered():
	$currBarDisplay7.show()
	pass # Replace with function body.


func _on_currgene7_mouse_exited():
	$currBarDisplay7.hide()
	pass # Replace with function body.


func _on_currgene8_mouse_entered():
	$currBarDisplay8.show()
	pass # Replace with function body.


func _on_currgene8_mouse_exited():
	$currBarDisplay8.hide()
	pass # Replace with function body.


func _on_currgene9_mouse_entered():
	$currBarDisplay9.show()
	pass # Replace with function body.


func _on_currgene9_mouse_exited():
	$currBarDisplay9.hide()
	pass # Replace with function body.
