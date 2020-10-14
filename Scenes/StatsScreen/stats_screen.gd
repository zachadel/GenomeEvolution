extends Panel
#Organization

#This will 
var turnsSurvived = STATS.get_rounds()
var resourcesConsumed = STATS.get_resources_consumed()
var spacesExplored = STATS.get_tiles_traveled()
var progenyProduced = STATS.get_progeny()

#Repairs 
var damagedGenesRepairedPerfect = STATS.get_dmg_genes_no_error()
var damagedGenesRepairedError = STATS.get_dmg_genes_error()
var tileTrimmedBreakEnds #FIND ME
var breaksRepairedJoinEndsPerfect = STATS.get_breaks_join()
var breaksRepairedJoinEndsError = STATS.get_breaks_join_error()
var breaksRepairedCopyRepairePerfect = STATS.get_breaks_cpyRepair_no_error()
var breaksRepairedCopyRepairError = STATS.get_breaks_cpyRepair_error()
var tilesCopiedGenes = STATS.get_tiles_copied_cpyRepair()
var tilesCopiedTotal #FIND ME
var tilesCorrectedCopyRepair = STATS.get_tiles_crctd_cpyRepair()
var breaksRepairedCollapseDuplicates = STATS.get_break_repaired_collapseDuplicates()
var tilesRemovedCollapseDuplicates #FIND ME

#Evolution
var majorUpgrades = STATS.get_majorUpgrades()
var majorDowngrades = STATS.get_majorDowngrades()
var minorUpgrades = STATS.get_minorUpgrades()
var minorDowngrades = STATS.get_minorDowngrades()
var upgradesInNewGene = STATS.get_majorUpgrades_blankTiles_newGene()
var downgradesInPseudogene #FIND ME
var skillsGained = STATS.get_num_skills()
var skillsLost #FIND ME
var TEFuseGene #FIND ME
var geneSplitByTE #FIND ME

#Composition
var blankTiles = STATS.get_final_blank_tiles()
var cat1
var cat2
var cat3
var cat4
var cat5
var cat6
var cat7
var cat8
var transposon_num = STATS.get_final_transposon_tiles()


# Called when the node enters the scene tree for the first time.
func _ready():
	$background.visible = false
	pass # Replace with function body.

func _headers():
	$background/surviveBox/surviveScore.text = turnsSurvived
	$background/consumeBox/consumeScore.text = resourcesConsumed
	$background/exploreBox/exploreScore.text = spacesExplored
	$background/produceBox/produceScore.text = progenyProduced
	pass

func _repairs():
	$background/repair1/dmg/dmg.text = damagedGenesRepairedError
	$background/repair1/rpr/repair.text = damagedGenesRepairedPerfect
	$background/repair2/dmg/dmg.text = tileTrimmedBreakEnds #NA
	$background/repair3/dmg/dmg.text = breaksRepairedJoinEndsError
	$background/repair3/rpr/repair.text = breaksRepairedJoinEndsPerfect
	#breaks repaired using copy repair
	$background/repair4/dmg/dmg.text = breaksRepairedCopyRepairError
	$background/repair4/rpr/repair.text = breaksRepairedCopyRepairePerfect
	#tiles copied
	$background/repair5/dmg/dmg.text = tilesCopiedGenes
	$background/repair5/rpr/repair.text = tilesCopiedTotal
	#tiles corrected
	$background/repair6/dmg/dmg.text = tilesCorrectedCopyRepair
	#breaks repaired collapse duplicate
	$background/repair8/dmg/dmg.text = breaksRepairedCollapseDuplicates
	#tiles removed using collapse duplicates
	$background/repair8/dmg/dmg.text = tilesRemovedCollapseDuplicates
	
	pass

func _evolves():
	#major upgrade and downgrade
	$background/majorUpDown/evc1/Down/downgrade.text = majorDowngrades
	$background/majorUpDown/evc1/upgrade.text = majorUpgrades
	#minor upgrade and downgrade
	$background/minorUpDown/evc2/Down/downgrade.text = minorDowngrades
	$background/minorUpDown/evc2/upgrade.text = minorUpgrades
	#new pseudo up down
	$background/newpseudoUpDown/evc4/Down/downgrade.text = downgradesInPseudogene
	$background/newpseudoUpDown/evc4/upgrade.text = upgradesInNewGene
	#skills gained and lost
	$background/skillsGainLoss/evc3/Down/downgrade.text = skillsLost
	$background/skillsGainLoss/evc3/upgrade.text = skillsGained
	#TEfuse
	$background/TEfuse/evc5/Down/downgrade.text = TEFuseGene
	#genes split
	$background/geneSplit/evc7/Down/downgrade.text = geneSplitByTE
	pass

func _composition():
	$background/tile_amt10/amt.text = blankTiles
	$background/maxCompositionBar/lBlue.rect_size.x = blankTiles  
	$background/maxCompositionBar/lorange.rect_size.x = transposon_num
	pass

func checkers():
	#header
	turnsSurvived = STATS.get_rounds()
	resourcesConsumed = STATS.get_resources_consumed()
	spacesExplored = STATS.get_tiles_traveled()
	progenyProduced = STATS.get_progeny()
	#Repairs 
	damagedGenesRepairedPerfect = STATS.get_dmg_genes_no_error()
	damagedGenesRepairedError = STATS.get_dmg_genes_error()
	#tileTrimmedBreakEnds #FIND ME
	breaksRepairedJoinEndsPerfect = STATS.get_breaks_join()
	breaksRepairedJoinEndsError = STATS.get_breaks_join_error()
	breaksRepairedCopyRepairePerfect = STATS.get_breaks_cpyRepair_no_error()
	breaksRepairedCopyRepairError = STATS.get_breaks_cpyRepair_error()
	tilesCopiedGenes = STATS.get_tiles_copied_cpyRepair()
	#tilesCopiedTotal #FIND ME
	tilesCorrectedCopyRepair = STATS.get_tiles_crctd_cpyRepair()
	breaksRepairedCollapseDuplicates = STATS.get_break_repaired_collapseDuplicates()
	#tilesRemovedCollapseDuplicates #FIND ME
	
	#Evolution
	majorUpgrades = STATS.get_majorUpgrades()
	majorDowngrades = STATS.get_majorDowngrades()
	minorUpgrades = STATS.get_minorUpgrades()
	minorDowngrades = STATS.get_minorDowngrades()
	upgradesInNewGene = STATS.get_majorUpgrades_blankTiles_newGene()
	#downgradesInPseudogene #FIND ME
	skillsGained = STATS.get_num_skills()
	#skillsLost #FIND ME
	#TEFuseGene #FIND ME
	#geneSplitByTE #FIND ME

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$WorldMap_UI.connect("show_stats", self, "_showScreen")
	$CardTable.connect("show_stats",self, "_showScreen")
	checkers() #checks to see if there is any change. I want this to be done when button pressed to get the page to come up
	_headers() #setting the values in the headers.
	_repairs()
	
func _showScreen():
	$background.visible = true


func _on_Button_pressed():
	$background.visible = false
