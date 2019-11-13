extends Node

const BASE_TTIPS = {
	"Replication": "Replication increases the probability for successful gene modifications.",
	"Locomotion": "Locomotion aids with movement in the world map.",
	"Manipulation": "Manipulation aids with the efficient use of resources.",
	"Sensing": "Sensing aids with the ability to sense nearby resources and to\ndetect the effectiveness of internal functions.",
	"Construction": "Construction increases the amount of energy and resources\nwhich can be banked for subsequent turns.",
	"Deconstruction": "Deconstruction aids with the breaking down of complicated\nresources into simpler, usable ones.",
	"Transposon": "Transposons are genetic parasites that can modify genes in various,\nunpredictable ways.",
	"Pseudogene": "Psuedogenes can still mutate, but are damaged to the point of inactivity."
};

const COMPARE_TTIPS = {
	"up": "\n\nThis behavior is improved compared to the copied chromosome.",
	"down": "\n\nThis behavior is worse compared to the copied chromosome.",
	"norm": "\n\nThis behavior is the same as the copied chromosome.",
	"dead": "\n\nThis behavior is missing from this chromosome.",
	"base": ""
};

const WORLDMAP_UI_TTIPS = {
	"acquire": "Acquire as many resources as you can on your current tile for %s energy.",
	"title": "Exit to the title screen.",
	"end_turn": "End the current map turn and proceed to the chromosome screen."
};

const GENE_TYPE_DESC = "This is a %s%s.";
const UNNAMED_GENES = ["Transposon", "Pseudogene"];
const GENE_TTIP_FORMAT = "%s\n\n%s";
const STATUS_TTIP_FORMAT = "%s%s";

func get_gene_ttip(type):
	var gene_title = " gene";
	if (type in GENE_TTIP_FORMAT):
		gene_title = "";
	return GENE_TTIP_FORMAT % [(GENE_TYPE_DESC % [type, gene_title]), BASE_TTIPS[type]];

func get_status_ttip(type, compare):
	return STATUS_TTIP_FORMAT % [BASE_TTIPS[type], COMPARE_TTIPS[compare]];
