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
	add_child(HTTP);
	HTTP.connect("request_completed", self, "_on_HTTP_request_completed");

func sanitize_replace(s : String) -> String:
	for k in SANITIZE_DICT:
		s = s.replace(k, SANITIZE_DICT[k]);
	return s;

func exp_save_code(code : String) -> void:
	OS.set_clipboard(code);
	var txt = "%s?sid=%d&code=%s" % [SAVE_SITE, save_id, sanitize_replace(code)];
	
	request_queue.append("%s?sid=%d&code=%s" % [SAVE_SITE, save_id, txt]);
	if request_queue.size() == 1:
		_pop_request();

func _pop_request():
	var err = HTTP.request(request_queue.front());
	if err != OK:
		print("http error! ", err);

func _on_HTTP_request_completed(result, response_code, headers, body):
	request_queue.remove(0);
	if request_queue.size() > 0:
		_pop_request();