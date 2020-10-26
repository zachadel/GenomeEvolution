extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_replication_value
var current_locomotion_value
var current_helper_value
var current_manipulation_value
var current_sensing_value
var current_component_value
var current_construction_value
var current_deconstruction_value
var current_ate_value

var max_replication_value =100
#var max_locomotion_value=100
var max_helper_value=100
var max_manipulation_value=100
var max_sensing_value=100
var max_component_value
var max_construction_value
var max_deconstruction_value
var max_ate_value

var maxBarGene1Size
var maxBarGene2Size
var maxBarGene3Size
var maxBarGene4Size
var maxBarGene5Size

var maxBarGene1Pos
var maxBarGene2Pos
var maxBarGene3Pos
var maxBarGene4Pos
var maxBarGene5Pos
func _set_bars():
	#Setting values
	max_replication_value = 100
	var max_locomotion_value = 100
	max_helper_value = 100
	max_manipulation_value = 100
	max_sensing_value = 100
	# The total length is of 490.
	# Here, we are setting up the bars porportionally.
	
	var maxBarSize = max_replication_value + max_locomotion_value + max_helper_value + max_manipulation_value + max_sensing_value;
	var maxBarGeneSize = 490 * .2
	maxBarGene2Size = 490 * (max_locomotion_value/maxBarSize)
	#maxBarGene3Size = 490 * (max_helper_value/maxBarSize)
	#maxBarGene4Size = 490 * (max_manipulation_value/maxBarSize)
	#maxBarGene5Size = 490 * (max_sensing_value/maxBarSize)
	
	maxBarGene1Pos = 10
	maxBarGene2Pos = 10 + maxBarGeneSize + maxBarGene1Pos
	#maxBarGene3Pos = 10 + maxBarGene2Size + maxBarGene2Pos
	#maxBarGene4Pos = 10 + maxBarGene3Size + maxBarGene3Pos
	#maxBarGene5Pos = 10 + maxBarGene4Size + maxBarGene4Pos
	
	$sub1/maxBar/gene1.rect_position.x = 10
	$sub1/maxBar/gene1.rect_size.x = maxBarGeneSize
	$sub1/maxBar/gene1.rect_position.y = 10
	
	$sub1/maxBar/gene2.rect_position.x = maxBarGene2Pos
	$sub1/maxBar/gene2.rect_size.x = maxBarGene2Size
	$sub1/maxBar/gene2.rect_position.y = 10
	
	#$sub1/maxBar/gene3.rect_position.x = maxBarGene3Pos
	#$sub1/maxBar/gene3.rect_size.x = maxBarGene3Size
	
	#$sub1/maxBar/gene4.rect_position.x = maxBarGene4Pos
	#$sub1/maxBar/gene4.rect_size.x = maxBarGene4Size
	
	#$sub1/maxBar/gene5.rect_position.x = maxBarGene5Pos
	#$sub1/maxBar/gene5.rect_size.x = maxBarGene5Size
	

func _set_values():
	#setting values for the current bar's value.
	current_replication_value = STATS.get_currentRep()
	current_locomotion_value = STATS.get_currentLoc()
	current_helper_value = STATS.get_currentHelp()
	current_manipulation_value = STATS.get_currentManip()
	current_sensing_value = STATS.get_currentSens()
	current_component_value = STATS.get_currentComp()
	current_construction_value = STATS.get_currentCon()
	current_deconstruction_value = STATS.get_currentDeCon()
	current_ate_value = STATS.get_currentAte()
	#setting values for the max bar's values. 
	max_replication_value = STATS.get_maxRep()
	#max_locomotion_value = STATS.get_maxLocomo()
	max_helper_value = STATS.get_maxHelp()
	max_manipulation_value = STATS.get_maxManip()
	max_sensing_value = STATS.get_maxSens()
	max_component_value = STATS.get_maxComp()
	max_construction_value = STATS.get_maxCon()
	max_deconstruction_value = STATS.get_maxDecon()
	max_ate_value = STATS.get_maxAte()

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	visible = false
	_set_bars()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_mouse_entered():
	$mainStat1/labelMaker/Label.show()

func _on_mouse_exited():
	$mainStat1/labelMaker/Label.hide()

func _on_StatsScreen_pressed():
	#set values
	#update the bar
	#update the interface
	visible = true
	pass # Replace with function body.


func _on_stats_screen_pressed():
	#set values
	#update the interface
	#update the bar
	visible = true
	pass # Replace with function body.


func _on_back_pressed():
	visible = false
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
