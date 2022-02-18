extends Control

var rng = RandomNumberGenerator.new()
var topics =["eat", "explore", "repair","replication","genome"];
var currentOutOf = 1;
onready var title_bar = $Background/Label;
onready var progress_bar = $Background/ProgressBar;
var current_mission = ""
var completed_missions = [];
var organized_missions1 ={
	"eat":[
		{"eat 2 sugars": false},
		{"eat 2 amino acids": false},
		{"eat 2 simple fats": false},
		{"eat 2 proteins": false},
		{"eat 2 complex carbohydrates": false},
		{"eat 2 fats": false},
		{"eat till the Fe border is green": false}, #ask about this one.
		{"eat till the Ca border is green": false},
		{"eat till the Na border is green": false},
		{"eat till the P border is green": false},
		{"eat till the Hg border is green": false}
	],
	"explore":[
		{"explore any 5 tiles": false},
		{"Uncover 10 hidden tiles": false},
		{"Uncover 20 hidden tiles": false},
		{"Uncover 30 hidden tiles": false},
		{"Uncover 40 hidden tiles": false},
		{"Uncover 50 hidden tiles": false}
	],
	"repair":[
		{"Fix 3 damaged genes": false},
		{"Fix 5 damaged genes": false},
		{"Fix 7 damaged genes": false},
		{"Fix 10 damaged genes": false},
		{"Perform 2 Join Ends Successfully": false},
		{"Perform 4 Join Ends Successfully": false},
		{"Perform 6 Join Ends Successfully": false},
		{"Perform 8 Join Ends Successfully": false},
		{"Perform 10 Join Ends Successfully": false},
		{"Turn 1 Transposon into a pseudogene": false},
		{"Turn 3 Transposons into pseudogenes": false},
		{"Turn 5 Transposons into pseudogenes": false},
		{"Turn 7 Transposons into pseudogenes": false},
		{"Turn 11 Transposons into pseudogenes": false},
		{"Perform copy-pair to generate 1 new tile": false},
		{"Perform copy-pair to generate 3 new tiles": false},
		{"Perform copy-pair to generate 5 new tiles": false},
		{"Perform copy-pair to generate 7 new tiles": false},
		{"Perform copy-pair to generate 11 new tiles": false},
		{"Perform copy-pair to generate 1 new gene": false},
		{"Perform copy-pair to generate 3 new gene": false},
		{"Perform copy-pair to generate 5 new gene": false},
		{"Perform copy-pair to generate 7 new gene": false},
		{"Perform copy-pair to generate 11 new gene": false},
		{"Perform 1 inversion during repair": false},
		{"Perform 3 inversions during repair": false},
		{"Perform 5 inversions during repair": false},
		{"Merge 1 Gene": false},
		{"Merge 3 Genes": false},
		{"Merge 5 Genes": false},
		{"Split 1 Gene": false},
		{"Split 3 Genes": false},
		{"Split 5 Genes": false},
	],
	"replication":[
		{"Perform Mitosis 1 time": false},
		{"Perform Mitosis 2 times": false},
		{"Perform Mitosis 3 times": false},
		{"Learn 1 new skill.":false},
		{"Learn 3 new skills.":false},
		{"Learn 5 new skills.":false}
	],
	"genome":[
		{"Add 1 new transposon type to the composition of your genome": false},
		{"Add 3 new transposon types to the composition of your genome": false},
		{"Add 5 new transposon types to the composition of your genome": false},
		
	]
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	setMission("testing");
	progressBar(1,2);
	updateMission();
	print("here")
	pass # Replace with function body.

func updateMission():
	var category = -1;
	var string_category = ""
	#Check to see if the first value is in there.
	if title_bar.text == "testing":
		completed_missions.append(title_bar.text)
		# choose randomly from the categories.
		category = rng.randi_range(0,4)
		match category:
			0: #eat
				string_category = "eat";
			1: #explore
				string_category = "explore";
			2:  #repair
				string_category = "repair";
			3: #replication
				string_category = "replication";
			4: #genome
				string_category = "genome";
		# Looking through keys.
		# Running through the obj to if it's in there or not.
		for i in organized_missions1[string_category]:
			if not i.values()[0]:
				var prompt = i.keys()[0];
				setMission(prompt);
				completed_missions.append(prompt)
				i[prompt] = true #this takes it out of the pool that I'm looking for.
				
func reshuffle(): #function that outputs a new missions from any category and any order.
	
	pass

func setMission(mission):
	title_bar.text =  str(mission);

func progressBar(progress, outOf): #pass in a percentage here.
	var percent = progress/outOf;
	progress_bar.value = percent * 100;

func reDraw():
	#if a mission is too difficult, redraw from the entirety of the missions. 
	pass


func progressMission(category, mission):
	#on the off chacne someone uses this to debug.
	var missions_ind = organized_missions1[category].find(mission)
	if missions_ind == -1:
		return -1
	else:
		print(missions_ind)
		currentOutOf = mission.to_int()
		# I want to parse the string for numeric characters, and then pull them out
		# that will be the new outOf vlaue. 
		
		#Now i need to pull out a value from the current statistics to see if we're moving along with it. 
		
		#stats.check_progress(mission_ind)
		
		# Query for the updates, and update the display as they go up. 
		# on every new mission, set the current progress to 0
		# 
		
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
