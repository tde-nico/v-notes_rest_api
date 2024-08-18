module main

import json

struct CustomResponse {
	status int
	message string
}

fn (c CustomResponse) to_json() string {
	return json.encode(c)
}

const invalid_json = "Invald JSON Payoload"
const note_not_found = "Note not found"
const unique_message = "Please provide a unique message for Note"
