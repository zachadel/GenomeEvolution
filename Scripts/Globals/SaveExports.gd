extends Node

# Couldn't get this to work on the TAMU page due to file permissions, so I'm using my personal site
# Directory of the saves is at https://itsalxl.com/genome_saves/
const SAVE_SITE = "https://itsalxl.com/genome_saves/save.php";
onready var save_id := OS.get_unix_time();

const SANITIZE_DICT = {
	"\n": "  |  "
};

var HTTP := HTTPRequest.new();
var request_queue := [];

func _ready():
# warning-ignore:return_value_discarded
	HTTP.connect("request_completed", self, "_on_HTTP_request_completed");
	add_child(HTTP);

func get_save_str(card_table):
	var savestr = var2str([Game.turn_idx, Game.round_num, card_table.orgn.get_save(), card_table.orgn.get_gene_pool()]).replace("\n", "")
	exp_save_code(savestr);
	return savestr

func load_from_save(save, card_table):
	var s = str2var(save)
	Game.turn_idx = int(s[0]) - 1
	Game.round_num = int(s[1])
	card_table.orgn.load_from_save(s[2])
	card_table.orgn.reproduct_gene_pool = s[3]

func sanitize_replace(s: String) -> String:
	for k in SANITIZE_DICT:
		s = s.replace(k, SANITIZE_DICT[k]);
	return s.http_escape();

const NO_CLIPBOARD_OS = ["HTML5", "Server"];
func exp_save_code(code: String) -> void:
	if !(OS.get_name() in NO_CLIPBOARD_OS):
		OS.set_clipboard(code);
	_send_to_web(sanitize_replace(code));

func flag_bug(bug_desc: String) -> void:
	var full_bug_desc = sanitize_replace("!!BUG from %s: %s" % [save_id, bug_desc]);
	_send_to_web("   ");
	_send_to_web(full_bug_desc);
	_send_to_web(full_bug_desc, "bug_log");
	_send_to_web("   ");

func _send_to_web(s: String, web_file: String = str(save_id)) -> void:
	request_queue.append("%s?sid=%s&code=%s" % [SAVE_SITE, web_file, s]);
	if request_queue.size() == 1:
		_pop_request();

func _pop_request() -> void:
	var err = HTTP.request(request_queue.front());
	if err != OK:
		print("http error! ", err);

func _on_HTTP_request_completed(_result, _response_code, _headers, _body) -> void:
	request_queue.remove(0);
	if request_queue.size() > 0:
		_pop_request();
