extends Panel
#sets for the max bar
var gene2_xPos_max
var gene3_xPos_max
var gene4_xPos_max
var gene5_xPos_max
#sets for the total bar
var gene2_xPos_total
var gene3_xPos_total
var gene4_xPos_total
var gene5_xPos_total

func _mainStats():
	$mainStat1/score.text = "12"
	$mainStat2/score.text = "12"
	$mainStat3/score.text = "12"
	$mainStat4/score.text = "12"

func _barSize():
	$sub1/maxBar/gene1.rect_size.x = 12
	
	gene2_xPos_max = 10 + $sub1/maxBar/gene1.rect_size.x + $sub1/maxBar/gene1.rect_position.x
	$sub1/maxBar/gene2.rect_position.x = gene2_xPos_max
	$sub1/maxBar/gene2.rect_size.x = 100
	
	gene3_xPos_max = gene2_xPos_max + 10 + $sub1/maxBar/gene2.rect_size.x
	$sub1/maxBar/gene3.rect_position.x = gene3_xPos_max
	$sub1/maxBar/gene3.rect_size.x = 12
	
	gene4_xPos_max = gene3_xPos_max + 10 + $sub1/maxBar/gene3.rect_size.x
	$sub1/maxBar/gene4.rect_position.x = gene4_xPos_max
	$sub1/maxBar/gene4.rect_size.x = 12
	
	gene5_xPos_max= gene4_xPos_max + 10 + $sub1/maxBar/gene4.rect_size.x
	$sub1/maxBar/gene5.rect_position.x = gene5_xPos_max
	$sub1/maxBar/gene5.rect_size.x = 12
	#total score bar variable size, don't touch y
	
	$sub1/currentBar/gene1.rect_size.x = 12
	
	gene2_xPos_total = 10 + $sub1/currentBar/gene1.rect_size.x + $sub1/currentBar/gene1.rect_position.x
	$sub1/currentBar/gene2.rect_position.x = gene2_xPos_total
	$sub1/currentBar/gene2.rect_size.x = 100
	
	gene3_xPos_total = gene2_xPos_total + 10 + $sub1/currentBar/gene2.rect_size.x
	$sub1/currentBar/gene3.rect_position.x = gene3_xPos_total
	$sub1/currentBar/gene3.rect_size.x = 12
	
	gene4_xPos_total = gene3_xPos_total + 10 + $sub1/currentBar/gene3.rect_size.x
	$sub1/currentBar/gene4.rect_position.x = gene4_xPos_total
	$sub1/currentBar/gene4.rect_size.x = 12
	
	gene5_xPos_total= gene4_xPos_total + 10 + $sub1/currentBar/gene4.rect_size.x
	$sub1/currentBar/gene5.rect_position.x = gene5_xPos_total
	$sub1/currentBar/gene5.rect_size.x = 12
	
func _ready():
	_mainStats()
	_barSize()
	#max score bar variable size, don't touch y
	
