extends CanvasLayer

func _ready():
	TooltipPanel.visible = false;

#	.d88888b    dP            oo                       a88888b.                              dP                                dP   oo                   
#	88.    "'   88                                    d8'   `88                              88                                88                        
#	`Y88888b. d8888P 88d888b. dP 88d888b. .d8888b.    88        .d8888b. 88d888b. .d8888b. d8888P 88d888b. dP    dP .d8888b. d8888P dP .d8888b. 88d888b. 
#	      `8b   88   88'  `88 88 88'  `88 88'  `88    88        88'  `88 88'  `88 Y8ooooo.   88   88'  `88 88    88 88'  `""   88   88 88'  `88 88'  `88 
#	d8'   .8P   88   88       88 88    88 88.  .88    Y8.   .88 88.  .88 88    88       88   88   88       88.  .88 88.  ...   88   88 88.  .88 88    88 
#	 Y88888P    dP   dP       dP dP    dP `8888P88     Y88888P' `88888P' dP    dP `88888P'   dP   dP       `88888P' `88888P'   dP   dP `88888P' dP    dP 
#	                                           .88                                                                                                       
#	                                       d8888P                                                                                                        

const BASE_TTIPS = {
	"Replication": "Replication increases the probability for successful gene modifications.",
	"Locomotion": "Locomotion aids with movement in the world map.",
	"Manipulation": "Manipulation aids with the efficient use of resources.",
	"Sensing": "Sensing aids with the ability to sense nearby resources and to detect the effectiveness of internal functions.",
	"Construction": "Construction increases the amount of energy and resources which can be banked for subsequent turns.",
	"Deconstruction": "Deconstruction aids with the breaking down of complicated resources into simpler, usable ones.",
	"Transposon": "Transposons are genetic parasites that can modify genes in various, unpredictable ways.",
	"Pseudogene": "Psuedogenes can still mutate, but are damaged to the point of inactivity."
};

const COMPARE_TTIPS = {
	"up": "This behavior is improved compared to the copied chromosome.",
	"down": "This behavior is worse compared to the copied chromosome.",
	"norm": "This behavior is the same as the copied chromosome.",
	"dead": "This behavior is missing from this chromosome.",
	"base": ""
};

const WORLDMAP_UI_TTIPS = {
	"acquire": "Acquire as many resources as you can on your current tile for %s energy.",
	"title": "Exit to the title screen.",
	"end_turn": "End the current map turn and proceed to the chromosome screen.",
	"energy": "Energy: %.2f",
	"resource": "%s: %.2f",
	"mineral_level": "Current: %.2f\nMaximum: %.2f\nMinimum: %.2f"
};

const WORLDMAP_TTIPS = {
	"resource_on_tile": "This is %s and it is a %s."
};

const GENE_TYPE_DESC = "This is a %s%s.";
const UNNAMED_GENES = ["Transposon", "Pseudogene"];
const GENE_TTIP_FORMAT = "%s\n\n%s";
const STATUS_TTIP_FORMAT = "%s\n\n%s";

func get_gene_ttip(type):
	var gene_title = " gene";
	if (type in UNNAMED_GENES):
		gene_title = "";
	return GENE_TTIP_FORMAT % [(GENE_TYPE_DESC % [type, gene_title]), BASE_TTIPS[type]];

func get_status_ttip(type, compare):
	return STATUS_TTIP_FORMAT % [BASE_TTIPS[type], COMPARE_TTIPS[compare]];


#	888888ba  oo                   dP                   
#	88    `8b                      88                   
#	88     88 dP .d8888b. 88d888b. 88 .d8888b. dP    dP 
#	88     88 88 Y8ooooo. 88'  `88 88 88'  `88 88    88 
#	88    .8P 88       88 88.  .88 88 88.  .88 88.  .88 
#	8888888P  dP `88888P' 88Y888P' dP `88888P8 `8888P88 
#	                      88                        .88 
#	                      dP                    d8888P  

onready var TooltipPanel := $PnlTooltip;
onready var TooltipTitle := $PnlTooltip/LblTitle;
onready var TooltipBody := $PnlTooltip/LblDesc;
onready var DelayTimer := $TooltipDelayTimer;

var delay_payload = [];
# callback is the func here in Tooltips.gd that will be called after the delay finishes
# args is an array of the arguments to be sent to that callback func
func delay_disp_cb(callback : String, args : Array, delay := -1.0):
	delay_payload = [callback, args];
	DelayTimer.start(delay);

func _on_DelayTimer_timeout():
	callv(delay_payload[0], delay_payload[1]);

func cancel_delay_disp():
	delay_payload.clear();
	DelayTimer.stop();
	TooltipPanel.visible = false;

func delay_disp(body : String, title : String = "", pos = null):
	delay_disp_cb("disp_tooltip", [body, title, pos]);


# Body is the body text, title is the title text, pos is where it appears
# Pos can be either a Node2D, a Control, or null to use the current mouse position
func disp_tooltip(body : String, title : String = "", pos = null):
	if (body == "" && title == ""):
		TooltipPanel.visible = false;
	else:
		TooltipPanel.visible = true;
		TooltipBody.text = body;
		TooltipTitle.text = title;
		if (pos == null):
			pos = TooltipPanel.get_global_mouse_position();
		elif (typeof(pos) != TYPE_VECTOR2):
			if ("position" in pos):
				var fn : Node2D;
				pos = pos.get_global_transform().get_origin() + Vector2(pos.size.x, 0);
			if ("rect_position" in pos):
				pos = pos.get_global_rect().position + Vector2(pos.rect_size.x, 0);
		
		var _px = clamp(pos.x, 0, get_viewport().size.x - TooltipPanel.rect_size.x);
		var _py = clamp(pos.y, TooltipPanel.rect_size.y, get_viewport().size.y) - TooltipPanel.rect_size.y;
		TooltipPanel.rect_position = Vector2(_px, _py);

func disp_gene_ttip(type, pos = null):
	var gene_title = "%s Gene";
	if (type in UNNAMED_GENES):
		gene_title = "%s";
	disp_tooltip(BASE_TTIPS[type], gene_title % type, pos);

func disp_status_ttip(type, compare, pos = null):
	disp_tooltip(STATUS_TTIP_FORMAT % [BASE_TTIPS[type], COMPARE_TTIPS[compare]], type, pos);

#	dP     dP           dP                                     
#	88     88           88                                     
#	88aaaaa88a .d8888b. 88 88d888b. .d8888b. 88d888b. .d8888b. 
#	88     88  88ooood8 88 88'  `88 88ooood8 88'  `88 Y8ooooo. 
#	88     88  88.  ... 88 88.  .88 88.  ... 88             88 
#	dP     dP  `88888P' dP 88Y888P' `88888P' dP       `88888P' 
#	                       88                                  
#	                       dP                                  

# Rather than setting up mouse_entered and mouse_exited signals on every single node,
# just call setup_delay_handler(self) and include a get_tooltip_data() func
# get_tooltip_data() should return an array [callback, args, delay] (delay is optional)
# i.e. get_tooltip_data() is used as the args for delay_disp_cb
var handled_controls = {};
func setup_delayed_tooltip(for_node : Control):
	for_node.connect("mouse_entered", self, "_handle_mouse_enter", [for_node]);
	for_node.connect("mouse_exited", self, "_handle_mouse_exit");

func _handle_mouse_enter(for_node : Control):
	if for_node.has_method("get_tooltip_data"):
		callv("delay_disp_cb", for_node.get_tooltip_data());
	elif "tooltip_text" in for_node:
		delay_disp(for_node.tooltip_text);
	else:
		disp_tooltip("You need to include either String tooltip_text or func get_tooltip_data() in nodes that make use of the delayed tooltip handler.", "No data!");
func _handle_mouse_exit():
	cancel_delay_disp();
