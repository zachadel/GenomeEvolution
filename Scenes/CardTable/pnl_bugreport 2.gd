extends Panel

var result = {}
var response = 0;
var token = Actions.env['token']

func set_result(res):
	result = res
	
func set_respoonse(response_code):
	response = response_code

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect('request_completed', self, '_on_request_completed')


func _make_post_request(title, description):
	var url = 'https://api.github.com/repos/zachadel/GenomeEvolutiFon/issues'
	
	var headers = [
		'Content-Type: application/json',
		'Authorization: token ' + token,
	]
	
	var data_to_send = {
		"title": title,
		"body": description,
		"labels": [
			"bug"
		]
	}
	var query = JSON.print(data_to_send)
	
	$HTTPRequest.request(url, headers, true, HTTPClient.METHOD_POST, query)


func _on_request_completed(result, response_code, headers, body):
	var res = JSON.parse(body.get_string_from_utf8())
	set_result(res.result)
	set_respoonse(response_code)
