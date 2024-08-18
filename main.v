module main

import vweb
import db.sqlite

struct App {
	vweb.Context
mut:
	db sqlite.DB
}

fn main() {
	db := sqlite.connect('notes.db') or { panic(err) }
	db.exec('drop table if exists Notes') or { panic(err) }
	sql db {
		create table Note
	} or { panic(err) }
	http_port := 8080
	app := &App{
		db: db
	}
	vweb.run(app, http_port)
}

@['/'; get]
fn (mut app App) hello() vweb.Result {
	return app.text('Welcome to V Notes')
}
