extends Panel
signal show_cardTable

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
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
	current_replication_value = 0;
	var currentBarSize = 1+current_replication_value + current_locomotion_value + current_helper_value + current_manipulation_value + current_sensing_value + current_component_value + current_construction_value + current_deconstruction_value + current_ate_value;
	var thisSize = 550 - 100;
	#S$Label.text = str(currentBarSize)
	currentBarGene1Size = thisSize * current_replication_value / currentBarSize;
	currentBarGene2Size = thisSize * current_locomotion_value / currentBarSize;
	currentBarGene3Size = thisSize * current_helper_value / currentBarSize;
	currentBarGene4Size = thisSize * current_manipulation_value / currentBarSize;
	currentBarGene5Size = thisSize * current_sensing_value / currentBarSize;
	currentBarGene6Size = thisSize * current_component_value / currentBarSize;
	currentBarGene7Size = thisSize * current_construction_value / currentBarSize;
	currentBarGene8Size = thisSize * current_deconstruction_value / currentBarSize;
	currentBarGene9Size = thisSize * current_ate_value / currentBarSize;
	
	currentBarGene1Pos = 10;
	currentBarGene2Pos = 10 + currentBarGene1Size + currentBarGene1Pos;
	currentBarGene3Pos = 10 + currentBarGene2Size + currentBarGene2Pos;
	currentBarGene4Pos = 10 + currentBarGene3Size + currentBarGene3Pos;
	currentBarGene5Pos = 10 + currentBarGene4Size + currentBarGene4Pos;
	currentBarGene6Pos = 10 + currentBarGene5Size + currentBarGene5Pos;
	currentBarGene7Pos = 10 + currentBarGene6Size + currentBarGene6Pos;
	currentBarGene8Pos = 10 + currentBarGene7Size + currentBarGene7Pos;
	currentBarGene9Pos = 10 + currentBarGene8Size + currentBarGene8Pos;
	
	$sub1/currentBar/gene1.rect_position.x = currentBarGene1Pos
	$sub1/currentBar/gene1.rect_size.x = currentBarGene1Size
	$sub1/currentBar/gene2.rect_position.x = currentBarGene2Pos
	$sub1/currentBar/gene2.rect_size.x = currentBarGene2Size
	$sub1/currentBar/gene3.rect_position.x = currentBarGene3Pos
	$sub1/currentBar/gene3.rect_size.x = currentBarGene3Size
	$sub1/currentBar/gene4.rect_position.x = currentBarGene4Pos
	$sub1/currentBar/gene4.rect_size.x = currentBarGene4Size
	$sub1/currentBar/gene5.rect_position.x = currentBarGene5Pos
	$sub1/currentBar/gene5.rect_size.x = currentBarGene5Size
	$sub1/currentBar/gene6.rect_position.x = currentBarGene6Pos
	$sub1/currentBar/gene6.rect_size.x = currentBarGene6Size
	$sub1/currentBar/gene7.rect_position.x = currentBarGene7Pos
	$sub1/currentBar/gene7.rect_size.x = currentBarGene7Size
	$sub1/currentBar/gene8.rect_position.x = currentBarGene8Pos
	$sub1/currentBar/gene8.rect_size.x = currentBarGene8Size
	$sub1/currentBar/gene9.rect_position.x = currentBarGene9Pos
	$sub1/currentBar/gene9.rect_size.x = currentBarGene9Size
	pass

func _set_max_bar():
	#Setting values
	# The total length is of 490.
	# Here, we are setting up the bars porportionally.
	
	var maxBarSize = 1+max_replication_value + max_locomotion_value + max_helper_value + max_manipulation_value + max_sensing_value + max_component_value + max_construction_value + max_deconstruction_value + max_ate_value;
	var thisSize = 550 - 100
	maxBarGene1Size = thisSize * max_replication_value / maxBarSize;
	maxBarGene2Size = thisSize * max_locomotion_value / maxBarSize;
	maxBarGene3Size = thisSize * max_helper_value / maxBarSize;
	maxBarGene4Size = thisSize * max_manipulation_value / maxBarSize;
	maxBarGene5Size = thisSize * max_sensing_value / maxBarSize;
	maxBarGene6Size = thisSize * max_component_value / maxBarSize;
	maxBarGene7Size = thisSize * max_construction_value / maxBarSize;
	maxBarGene8Size = thisSize * max_deconstruction_value / maxBarSize;
	maxBarGene9Size = thisSize * max_ate_value / maxBarSize;
	
	maxBarGene1Pos = 10;
	maxBarGene2Pos = 10 + maxBarGene1Size + maxBarGene1Pos;
	maxBarGene3Pos = 10 + maxBarGene2Size + maxBarGene2Pos;
	maxBarGene4Pos = 10 + maxBarGene3Size + maxBarGene3Pos;
	maxBarGene5Pos = 10 + maxBarGene4Size + maxBarGene4Pos;
	maxBarGene6Pos = 10 + maxBarGene5Size + maxBarGene5Pos;
	maxBarGene7Pos = 10 + maxBarGene6Size + maxBarGene6Pos;
	maxBarGene8Pos = 10 + maxBarGene7Size + maxBarGene7Pos;
	maxBarGene9Pos = 10 + maxBarGene8Size + maxBarGene8Pos;
	
	$sub1/maxBar/gene1.rect_position.x = maxBarGene1Pos
	$sub1/maxBar/gene1.rect_size.x = maxBarGene1Size
	$sub1/maxBar/gene2.rect_position.x = maxBarGene2Pos
	$sub1/maxBar/gene2.rect_size.x = maxBarGene2Size
	$sub1/maxBar/gene3.rect_position.x = maxBarGene3Pos
	$sub1/maxBar/gene3.rect_size.x = maxBarGene3Size
	$sub1/maxBar/gene4.rect_position.x = maxBarGene4Pos
	$sub1/maxBar/gene4.rect_size.x = maxBarGene4Size
	$sub1/maxBar/gene5.rect_position.x = maxBarGene5Pos
	$sub1/maxBar/gene5.rect_size.x = maxBarGene5Size
	$sub1/maxBar/gene6.rect_position.x = maxBarGene6Pos
	$sub1/maxBar/gene6.rect_size.x = maxBarGene6Size
	$sub1/maxBar/gene7.rect_position.x = maxBarGene7Pos
	$sub1/maxBar/gene7.rect_size.x = maxBarGene7Size
	$sub1/maxBar/gene8.rect_position.x = maxBarGene8Pos
	$sub1/maxBar/gene8.rect_size.x = maxBarGene8Size
	$sub1/maxBar/gene9.rect_position.x = maxBarGene9Pos
	$sub1/maxBar/gene9.rect_size.x = maxBarGene9Size

func _update_values():
	num_progeny = STATS.get_progeny();
	tiles_explored = STATS.get_tiles_traveled();
	resources_consumed = STATS.get_resources_consumed();
	turns_taken = STATS.get_rounds();
	
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
	#setting values for the max bar's values. 
	max_replication_value = STATS.get_maxRep();
	#max_locomotion_value = STATS.get_maxLocomo()
	max_helper_value = STATS.get_maxHelp();
	max_manipulation_value = STATS.get_maxManip();
	max_sensing_value = STATS.get_maxSens();
	max_component_value = STATS.get_maxComp();
	max_construction_value = STATS.get_maxCon();
	max_deconstruction_value = STATS.get_maxDecon();
	max_ate_value = STATS.get_maxAte();
	
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
	geneSplit = STATS.get_elmSplit();
	
func _set_transposons():
	$sub1/AnthroArt.set_color(Color.red)
	$sub1/AnthroArt._set_texture("res:///Assets/Images/tes/hexagon_body.png")
func _set_values():
	#main values
	$mainStat1/score.text = str(turns_taken);
	$mainStat2/score.text = str(resources_consumed)
	$mainStat3/score.text = str(tiles_explored)
	$mainStat4/score.text = str(num_progeny)
	
	
	#Composition values
	var genesNumber = max_replication_value + max_locomotion_value + max_helper_value + max_manipulation_value + max_sensing_value + max_component_value + max_construction_value + max_deconstruction_value + max_ate_value;
	var currentNumber = current_replication_value + current_locomotion_value + current_helper_value + current_manipulation_value + current_sensing_value + current_component_value + current_construction_value + current_deconstruction_value + current_ate_value;
	if(genesNumber <= currentNumber):
		genesNumber = currentNumber;
	$sub1/currentBar/score/score_txt.text = str(currentNumber)
	$sub1/maxBar/score/score_txt.text = str(genesNumber)
	#gene composition
	$sub1/gene1/score/Label.text = str(current_replication_value)
	$sub1/gene2/score/Label.text = str(current_sensing_value)
	$sub1/gene3/score/Label.text = str(current_manipulation_value)
	$sub1/gene4/score/Label.text = str(current_component_value)
	$sub1/gene5/score/Label.text = str(current_construction_value)
	$sub1/gene6/score/Label.text = str(current_deconstruction_value)
	$sub1/gene7/score/Label.text = str(current_helper_value)
	$sub1/transposon2/score/Label.text = str(current_blank_value)
	#$sub1/transposon3/score/Label.text = str(0)
	# Repairs
	$sub2/rep1/rep1Score/score1Text.text = str(dmgGeneRepairPerfect)
	$sub2/rep1/rep1Score2/score2Text.text = str(dmgGeneRepairError)
	$sub2/rep2/rep1Score/score1Text.text = str(trimmedBreakEnds)
	$sub2/rep3/rep1Score/score1Text.text = str(breaksRepairedCopyRepairPerfect)
	$sub2/rep3/rep1Score2/score2Text.text = str(breaksRepairedCopyRepairError)
	$sub2/rep4/rep1Score/score1Text.text = str(breaksRepairedJoinEndsPerfect)
	$sub2/rep4/rep1Score2/score2Text.text = str(breaksRepairedJoinEndsError)
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
	#_set_transposons()
	_set_max_bar()
	_set_current_bar()
	_set_values()
	pass # Replace with function body.


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
