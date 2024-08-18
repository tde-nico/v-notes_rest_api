module main

import json
import vweb

@[table: 'Notes']
struct Note {
	id int @[primary; sql: serial]
	message string @[sql: 'detail'; unique]
	status bool
}

fn (n Note) to_json() string {
	return json.encode(n)
}

@['/notes'; post]
fn (mut app App) create() vweb.Result {
	n := json.decode(Note, app.req.data) or {
		app.set_status(400, 'Bad Request')
		er := CustomResponse{400, invalid_json}
		return app.json(er.to_json())
	}
	
	notes_found := sql app.db {
		select from Note where message == n.message
	} or { panic(err) }
	if notes_found.len > 0 {
		app.set_status(400, 'Bad Request')
		er := CustomResponse{400, unique_message}
		return app.json(er.to_json())
	}
	
	sql app.db {
		insert n into Note
	} or { panic(err) }
	new_id := app.db.last_id() as int
	note_created := Note{new_id, n.message, n.status}
	app.set_status(201, 'Created')
	app.add_header('Content-Location', '/notes/$new_id')
	return app.json(note_created.to_json())
}

@['/notes/:id'; get]
fn (mut app App) read(id int) vweb.Result {
	n := sql app.db {
		select form Note where id == id
	} or { panic(err) }
	if n[0].id != id {
		app.set_status(404, 'Not Found')
		er := CustomResponse{400, note_not_found}
		return app.json(er.to_json())
	}
	ret := json.encode(n[0])
	app.set_status(200, 'OK')
	return app.json(ret)
}

@['/notes/'; get]
fn (mut app App) read_all() vweb.Result {
	n := sql app.db {
		select from Note
	} or { panic(err) }
	ret := json.encode(n)
	app.set_status(200, 'OK')
	return app.json(ret)
}

@['/notes/:id'; put]
fn (mut app App) update(id int) vweb.Result {
	n := json.decode(Note, app.req.data) or {
		app.set_status(400, 'Bad Request')
		er := CustomResponse{400, invalid_json}
		return app.json(er.to_json())
	}

	note_to_update := sql app.db {
		select from Note where id == id
	} or { panic(err) }
	if note_to_update[0].id != id {
		app.set_status(404, 'Not Found')
		er := CustomResponse{404, note_not_found}
		return app.json(er.to_json())
	}

	res := sql app.db {
		select from Note where message == n.message && id != id
	} or { panic(err) }
	if res.len > 0 {
		app.set_status(400, 'Bad Request')
		er := CustomResponse{400, unique_message}
		return app.json(er.to_json())
	}

	sql app.db {
		update Note set message = n.message, status = n.status where id == id
	} or { panic(err) }
	updated_note := Note{id, n.message, n.status}
	ret := json.encode(updated_note)
	app.set_status(200, 'OK')
	return app.json(ret)
}

@['/notes/:id'; delete]
fn (mut app App) delete(id int) vweb.Result {
	sql app.db {
		delete from Note where id == id
	} or { panic(err) }
	app.set_status(204, 'No Content')
	return app.ok('')
}
