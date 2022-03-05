extends Control

var rng = RandomNumberGenerator.new()
var topics =["eat", "explore", "repair","replication","genome"];
var currentOutOf = 1;
onready var title_bar = $Background/Label;
onready var progress_bar = $Background/ProgressBar;
var current_mission = ""
var completed_missions_count =0;
var current_mission_category = ""
var current_mission_index = -1
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
		{"eat till the Hg border is green": false},
		{"eat till the N border is green": false}
		
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
		{"Fix 3 damaged genes": false},#0
		{"Fix 5 damaged genes": false},#1
		{"Fix 7 damaged genes": false},#2
		{"Fix 10 damaged genes": false},#3
		{"Perform 2 Join Ends Successfully": false}, #4
		{"Perform 4 Join Ends Successfully": false},#5
		{"Perform 6 Join Ends Successfully": false}, #6
		{"Perform 8 Join Ends Successfully": false}, #7
		{"Perform 10 Join Ends Successfully": false}, #8
		{"Turn 1 Transposon into a pseudogene": false}, #9
		{"Turn 3 Transposons into pseudogenes": false}, #10
		{"Turn 5 Transposons into pseudogenes": false},#11
		{"Turn 7 Transposons into pseudogenes": false}, #12
		{"Turn 11 Transposons into pseudogenes": false}, #13
		{"Perform copy-pair to generate 1 new tile": false},# 14
		{"Perform copy-pair to generate 3 new tiles": false}, #15
		{"Perform copy-pair to generate 5 new tiles": false},#16
		{"Perform copy-pair to generate 7 new tiles": false}, #17
		{"Perform copy-pair to generate 11 new tiles": false}, #18
		{"Perform copy-pair to generate 1 new gene": false},#19
		{"Perform copy-pair to generate 3 new gene": false},#20
		{"Perform copy-pair to generate 5 new gene": false}, #21
		{"Perform copy-pair to generate 7 new gene": false},#22
		{"Perform copy-pair to generate 11 new gene": false}, #23
		{"Perform 1 inversion during repair": false}, #24
		{"Perform 3 inversions during repair": false}, #25
		{"Perform 5 inversions during repair": false},#26
		{"Merge 1 Gene": false}, #27
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
	completed_missions_count=0
	setMission("testing");
	updateMission();
	
	print("here")
	pass # Replace with function body.

func updateMission():
	var category = -1;
	var string_category = ""
	#Check to see if the first value is in there
	var mission_index;
	if title_bar.text == "testing":
		# choose randomly from the categories.
		category = rng.randi_range(0,4)
		match category:
			0: #eat
				string_category = "eat";
				mission_index = rng.randi_range(0, 10)
				print("eat mission index: "+ str(mission_index))
			1: #explore
				string_category = "explore";
				mission_index = rng.randi_range(0, 5)
				print("explore mission index: "+ str(mission_index))
				#if mission_index > 0 and !organized_missions1[string_category][mission_index-1].values()[0]:
				#	continue
			2:  #repair
				string_category = "repair";
				mission_index = rng.randi_range(0, 32)
				print("repair mission index: "+ str(mission_index))
#				""" 
#				if mission_index > 0 and mission_index < 4 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue
#				elif mission_index > 4 and mission_index < 9 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue
#				elif mission_index > 9 and mission_index < 14 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue
#				elif mission_index > 14 and mission_index < 19 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue
#				elif mission_index > 19 and mission_index < 24 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue
#				elif mission_index > 24 and mission_index < 27 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue
#				elif mission_index > 27 and mission_index < 30 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue
#				elif mission_index > 30 and mission_index < 33 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue
#				"
			3: #replication
				string_category = "replication";
				mission_index = rng.randi_range(0, 5)
				print("replication mission index: "+ str(mission_index))
#				"""
#				if mission_index > 0 and mission_index < 3 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue
#				elif mission_index > 3 and mission_index < 6 and not organized_missions1[string_category][mission_index-1].values()[0] :
#					continue"""
			4: #genome
				string_category = "genome";
				mission_index = rng.randi_range(0, 2)
				print("genome mission index: "+ str(mission_index))
#				if mission_index > 0 and !organized_missions1[string_category][mission_index-1].values()[0]:
#					continue
		# Looking through keys.
		# Running through the obj to if it's in there or not.
	var prompt = organized_missions1[string_category][mission_index].keys()[0];
		#print(prompt)
		#This only gets called if the value is true. Else it just conitnues on. 
	var should_continue = false
	while(true): 
		print("Entered the loop")
		match category:
			0: #eat, genuinely any of these could be used
				mission_index = rng.randi_range(0, 10)
			1: #explore, each of these have to be in successive order.
				mission_index = rng.randi_range(0, 5)
				if mission_index > 0 and !organized_missions1[string_category][mission_index-1].values()[0]:
					print("Calling continue")
					should_continue = true
				else:
					should_continue = false
			2:  #repair
				mission_index = rng.randi_range(0, 32)
				if mission_index > 0 and mission_index < 4 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 4 and mission_index < 9 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 9 and mission_index < 14 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 14 and mission_index < 19 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 19 and mission_index < 24 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 24 and mission_index < 27 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 27 and mission_index < 30 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 30 and mission_index < 33 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				else:
					should_continue = false
			3: #replication
				mission_index = rng.randi_range(0, 5)
				if mission_index > 0 and mission_index < 3 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 3 and mission_index < 6 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				else:
					should_continue = false
			4: #genome
				mission_index = rng.randi_range(0, 3)
				if mission_index > 0 and !organized_missions1[string_category][mission_index-1].values()[0]:
					should_continue = true
				else:
					should_continue = false
		if should_continue:
			print("mission index: " + str(mission_index))
			continue
		prompt = organized_missions1[string_category][mission_index].keys()[0];
		if not organized_missions1[string_category][mission_index][prompt]:
			break
	print(prompt)
	setMission(prompt);
	set_currents(prompt, mission_index, string_category)
	STATS.mission_control(string_category, mission_index)

func set_currents(mission, mission_index, category):
	current_mission = mission
	current_mission_index = mission_index
	current_mission_category = category
	pass

func completeMission(category, index):
	completed_missions_count +=1
	if category == current_mission_category and index == current_mission_index:
		print("all good")
	else:
		print("Mission does not match the one completed.")
		return
	#add to the completed missions
	completed_missions.append(current_mission)
	#updates the database
	organized_missions1[current_mission_category][current_mission_index][current_mission] = true
	#set the stats value to be the length of the completed missions for the stats screen.

	STATS.set_missions_complete(completed_missions_count)
	
	$Background.color = Color(0.08,0.8,.15,1) #Green
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	$Background.color = Color(0,0,0,1) #grey black
	reshuffle()
	
	#perform the green animation now. 
	
	
	# set the value to true in the db.
	# perform the green light 
	pass

func reshuffle(): #function that outputs a new missions from any category and any order.
	var category = -1;
	var string_category = ""
	progressBar(0)
	category = rng.randi_range(0,4)
	var mission_index = -1;
	match category:
		0: #eat
			string_category = "eat";
			mission_index = rng.randi_range(0, 10)
		1: #explore
			string_category = "explore";
			mission_index = rng.randi_range(0, 5)
			if mission_index > 0 and !organized_missions1[string_category][mission_index-1].values()[0]:
				continue
		2:  #repair
			string_category = "repair";
			mission_index = rng.randi_range(0, 32)
			if mission_index > 0 and mission_index < 4 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
			elif mission_index > 4 and mission_index < 9 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
			elif mission_index > 9 and mission_index < 14 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
			elif mission_index > 14 and mission_index < 19 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
			elif mission_index > 19 and mission_index < 24 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
			elif mission_index > 24 and mission_index < 27 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
			elif mission_index > 27 and mission_index < 30 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
			elif mission_index > 30 and mission_index < 33 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
		3: #replication
			string_category = "replication";
			mission_index = rng.randi_range(0, 5)
			if mission_index > 0 and mission_index < 3 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
			elif mission_index > 3 and mission_index < 6 and not organized_missions1[string_category][mission_index-1].values()[0] :
				continue
		4: #genome
			string_category = "genome";
			mission_index = rng.randi_range(0, 2)
			if mission_index > 0 and !organized_missions1[string_category][mission_index-1].values()[0]:
				continue
		# Looking through keys.
		# Running through the obj to if it's in there or not.
	var prompt = organized_missions1[string_category][mission_index].keys()[0];
		#print(prompt)
		#This only gets called if the value is true. Else it just conitnues on. 
	var should_continue = false
	while(true): 
		print("Entered the loop")
		match category:
			0: #eat, genuinely any of these could be used
				mission_index = rng.randi_range(0, 10)
			1: #explore, each of these have to be in successive order.
				mission_index = rng.randi_range(0, 5)
				if mission_index > 0 and !organized_missions1[string_category][mission_index-1].values()[0]:
					print("Calling continue")
					should_continue = true
				else:
					should_continue = false
			2:  #repair
				mission_index = rng.randi_range(0, 32)
				if mission_index > 0 and mission_index < 4 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 4 and mission_index < 9 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 9 and mission_index < 14 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 14 and mission_index < 19 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 19 and mission_index < 24 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 24 and mission_index < 27 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 27 and mission_index < 30 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 30 and mission_index < 33 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				else:
					should_continue = false
			3: #replication
				mission_index = rng.randi_range(0, 5)
				if mission_index > 0 and mission_index < 3 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				elif mission_index > 3 and mission_index < 6 and not organized_missions1[string_category][mission_index-1].values()[0] :
					should_continue = true
				else:
					should_continue = false
			4: #genome
				mission_index = rng.randi_range(0, 3)
				if mission_index > 0 and !organized_missions1[string_category][mission_index-1].values()[0]:
					should_continue = true
				else:
					should_continue = false
		if should_continue:
			print("mission index: " + str(mission_index))
			continue
		prompt = organized_missions1[string_category][mission_index].keys()[0];
		if not organized_missions1[string_category][mission_index][prompt]:
			break
	print(prompt)
	setMission(prompt);
	set_currents(prompt, mission_index, string_category)
	STATS.mission_control(string_category, mission_index)


func setMission(mission):
	title_bar.text =  str(mission);

func progressBar(percent): #pass in a percentage here.
	progress_bar.value = percent * 100;


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


func _on_Button_pressed():
	reshuffle()

