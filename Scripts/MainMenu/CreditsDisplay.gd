tool
# makes the code run in the editor, so you can see the credits

extends Panel

# Build the credits from the /Data/credits.cfg file
# Helps keep formatting consistent, avoids those weird newline errors
func _ready():
	var cfg := ConfigFile.new();
	cfg.load("res://Data/credits.cfg");
	
	var RTL : RichTextLabel = $RichTextLabel;
	var just_started := true;
	RTL.clear();
	RTL.push_align(RichTextLabel.ALIGN_CENTER);
	for cat in cfg.get_sections():
		if just_started:
			just_started = false;
		else:
			RTL.newline();
			RTL.newline();
		
		if "license" in cat:
			RTL.push_bold()
			RTL.append_bbcode(cat.capitalize())
			RTL.pop()
			RTL.newline()
			RTL.newline()
			RTL.append_bbcode(cfg.get_value(cat, "text"))

		else:
			RTL.push_bold();
			RTL.append_bbcode(cfg.get_value(cat, "title"));
			RTL.pop();
			for p in cfg.get_value(cat, "ppl"):
				RTL.newline();
				RTL.append_bbcode(p);
	RTL.pop();
