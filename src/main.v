module main

import db.sqlite
import vweb
import os
import time

const (
	port       = os.getenv('PORT').int()
	start_time = time.now()
)

[noinit]
struct App {
	vweb.Context
mut:
	user ?&User
pub mut:
	db sqlite.DB
}

fn App.new(db sqlite.DB) App {
	return App{
		db: db
	}
}

fn init() {
	db := create_db_sqlite()
	sql db {
		create table User
		create table Feed
		create table FeedFollow
	} or { panic(err) }
}

fn main() {
	app := App.new(create_db_sqlite())
	vweb.run(&app, port)
}

struct HealthCheck {
	status string
	uptime i64
}

['/healthcheck'; get]
fn (mut app App) handle_health() vweb.Result {
	health := HealthCheck{
		status: 'ok'
		uptime: time.now().unix_time_milli() - start_time.unix_time_milli()
	}

	return app.json(health)
}

pub fn (mut app App) before_request() {
	app.header.add(.access_control_allow_origin, 'https://*, http://*')
	app.header.add(.access_control_allow_methods, 'GET, POST, PUT, DELETE, OPTIONS')
	app.header.add(.access_control_allow_headers, '*')
	app.header.add(.access_control_expose_headers, 'Link')
	app.header.add(.access_control_allow_credentials, 'false')
	app.header.add(.access_control_max_age, '300')

	api_key_cookie := app.req.cookies[auth_header_name]

	if !api_key_cookie.is_blank() {
		app.header.set_custom(auth_header_name, 'Api-Key ${api_key_cookie}') or { return }
	}

	app.user = app.get_current_user()
}

fn (mut app App) error[T](code int, err T) vweb.Result {
	app.set_status(code, '')

	return app.json[T](err)
}

fn (mut app App) created() vweb.Result {
	app.set_status(201, '')

	return app.text('')
}
