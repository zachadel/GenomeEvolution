extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# fix later 
var cell_type = "str($Organism.get_cell_type())"

var rounds = str(STATS.get_rounds()) #gets the number of rounds that were used
var progeny =  str(STATS.get_progeny())# gets the progeny when called
var death_reason = "str($Organism.is_viable())"
var gaps := 0 #

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#var cell_texture = Game.get_large_cell_path(cell_type, "body") # I'm going to need to set it to the path that I want it to be.
	if cell_type in Settings.settings["cells"]: #should set the texture for the body.
		var tex_path = ""
		tex_path = Game.get_large_cell_path(cell_type, "body")
			
		$BackDrop/DeadCell.texture = load(tex_path)
		
		for child in get_children(): # should set the texture for the nucleus
			if child is TextureRect:
				tex_path = Game.get_large_cell_path(cell_type, child.name.to_lower())
				child.texture = load(tex_path)
	
	for rtype in ["repair_cp", "repair_cd", "repair_je"]:
		gaps += Unlocks.get_count(rtype);
	var rank
	#This sets the ranks 
	if(int(rounds) <= 1):
		rank = "Crawler"
	elif(int(rounds) <= 2):
		rank = "Migrator"
	elif(int(rounds) < 5):
		rank = "Survivor"
	else:
		rank = "Alpha"
	#this calls the show screen image
	show_game_over(rank) #executes the above show image
	if($Timer.get_wait_time() == 0):
		$BackDrop.visible = false #at the end of the timer, screen goes away and the credits appear.
		$BackDrop/CrossBones.visible = false
		$BackDrop/DeadCell.visible = false
		$BackDrop/DeadCell/nucleaus.visible = false
		$BackDrop/Gaps.visible = false
		$BackDrop/GenomeRank.visible = false
		$BackDrop/Label.visible = false
		$BackDrop/ProgenyBegin.visible = false
		$BackDrop/ProgenyEnd.visible = false
		$BackDrop/RightDNA.visible = false
		$BackDrop/LeftDNA.visible = false
		$BackDrop/RoundsBegin.visible = false
		$BackDrop/RoundsEnd.visible = false
		$BackDrop/restart.visible = false 
		$HSplitContainer.visible = true

func show_game_over(rank): # show the right game over text
	$BackDrop/RoundsEnd.text = 'Final Rounds: '+rounds #this should assign the text value to the progeny values
	$BackDrop/ProgenyEnd.text = 'Total Progeny: ' +progeny
	$BackDrop/Gaps.text = 'You fixed '+ str(gaps) + ' gaps!'
	$BackDrop/GenomeRank.text = "Genome Rank: " + rank
	$BackDrop/DeathReason.text = "You Died because: "+death_reason
	#$deadCell.texture = cell_texture 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
