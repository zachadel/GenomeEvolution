extends AcceptDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#low_or_high: true = low, false = high
func show_high_low_warning(gene_type: String, low_or_high: bool = true, action_name: String = "that action"):
	var low_high = ""
	
	if low_or_high:
		low_high = "low"
	else:
		low_high = "high"
		
	dialog_text = "Warning! Your %s value is too %s to perform %s." % [gene_type, low_high, action_name]
	popup_centered()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
