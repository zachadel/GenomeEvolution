extends Control

#NOTE: It is the job of the nodes using this Bank to ensure
#that the carbs, fats, and proteins do not exceed the 
#proper amounts.
#NOTE: cfp stands for carbs, fats, proteins
var max_cfp_stored = 100.0
var max_minerals_stored = 50.0

var bar_size = Vector2(0,0)

var carbs = 20
var fats = 20
var proteins = 20

var minerals = 20

var current_cfp_total = carbs + fats + proteins
var current_mineral_total = minerals

# Called when the node enters the scene tree for the first time.
func _ready():
	bar_size = $Border.rect_size
	
	update_cfp_values(carbs, fats, proteins)
	update_mineral_values(minerals)

#This function takes the values and adds or subtracts the given values from them
func shift_cfp_values(carbs_shift, fats_shift, proteins_shift):
	return update_cfp_values(carbs + carbs_shift, fats + fats_shift, proteins + proteins_shift)


func shift_mineral_values(minerals_shift):
	return update_mineral_values(minerals + minerals_shift)


#This function overwrites each of the values
func update_cfp_values(_carbs, _fats, _proteins):
	if _carbs + _fats + _proteins <= max_cfp_stored:
		carbs = clamp(_carbs, 0, max_cfp_stored)
		fats = clamp(_fats, 0, max_cfp_stored)
		proteins = clamp(_proteins, 0, max_cfp_stored)
		
		current_cfp_total = carbs + fats + proteins
		
		$Carbs.rect_size = Vector2(carbs/max_cfp_stored * $Border.rect_size.x, $Border.rect_size.y)
		$Carbs.rect_position = $Border.rect_position
		$Carbs/Label.text = "Carbs: " + str(carbs)
		$Carbs/Label.rect_size = $Carbs.rect_size
		
		$Fats.rect_size = Vector2(fats/max_cfp_stored * $Border.rect_size.x, $Border.rect_size.y)
		$Fats.rect_position = $Carbs.rect_position + Vector2($Carbs.rect_size.x, 0)
		$Fats/Label.text = "Fats: " + str(fats)
		$Fats/Label.rect_size = $Fats.rect_size
		
		$Proteins.rect_size = Vector2(proteins/max_cfp_stored * $Border.rect_size.x, $Border.rect_size.y)
		$Proteins.rect_position = $Fats.rect_position + Vector2($Fats.rect_size.x, 0)
		$Proteins/Label.text = "Proteins: " + str(proteins)
		$Proteins/Label.rect_size = $Proteins.rect_size
		
		return true
		
	else:
		return false

func update_mineral_values(_minerals):
	if _minerals <= max_minerals_stored:
		minerals = clamp(_minerals, 0, max_minerals_stored)
		
		current_mineral_total = minerals
		
		$Minerals.rect_size = Vector2(minerals/max_minerals_stored * $MineralsBorder.rect_size.x, $MineralsBorder.rect_size.y)
		$Minerals.rect_position = $MineralsBorder.rect_position
		$Minerals/Label.text = "Minerals: " + str(minerals)
		$Minerals/Label.rect_size = $Minerals.rect_size
		
		return true
		
	else:
		return false