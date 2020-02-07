extends Node

# Couldn't get this to work on the TAMU page due to file permissions, so I'm using my personal site
# Directory of the saves is at https://itsalxl.com/genome_saves/
const SAVE_SITE = "https://itsalxl.com/genome_saves/save.php";
onready var save_id := OS.get_unix_time();

const SANITIZE_DICT = {
	" ": "%20",
	"'": "%5C'",
	"\\": ""
};

var HTTP := HTTPRequest.new();
var request_queue := [];

func _ready():
# warning-ignore:return_value_discarded
	HTTP.connect("request_completed", self, "_on_HTTP_request_completed");
	add_child(HTTP);

func sanitize_replace(s : String) -> String:
	for k in SANITIZE_DICT:
		s = s.replace(k, SANITIZE_DICT[k]);
	return s;

const NO_CLIPBOARD_OS = ["HTML5", "Server"];
func exp_save_code(code : String) -> void:
	if !(OS.get_name() in NO_CLIPBOARD_OS):
		OS.set_clipboard(code);
	
	request_queue.append("%s?sid=%d&code=%s" % [SAVE_SITE, save_id, sanitize_replace(code)]);
	if request_queue.size() == 1:
		_pop_request();

func _pop_request():
	var err = HTTP.request(request_queue.front());
	if err != OK:
		print("http error! ", err);

func _on_HTTP_request_completed(_result, _response_code, _headers, _body):
	request_queue.remove(0);
	if request_queue.size() > 0:
		_pop_request();
