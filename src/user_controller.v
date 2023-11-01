module main

import json
import vweb

struct CreateUserDto {
	name string [required]
}

['/v1/users'; get]
fn (mut app App) handle_get_all_users() vweb.Result {
	mut limit := app.query['limit'].int()
	offset := app.query['offset'].int()

	if limit == 0 {
		limit = 10
	}

	users := app.users_find_many(limit, offset)
	return app.json(users.to_dto())
}

['/v1/users'; post]
fn (mut app App) handle_create_user() vweb.Result {
	data := json.decode(CreateUserDto, app.req.data) or {
		app.set_status(400, '')
		return app.text('Invalid Body Json')
	}

	app.users_insert(User.new(data.name)) or {
		app.set_status(422, '')
		return app.text('Failed to insert user ${err.msg()}')
	}

	app.set_status(201, '')
	return app.text('')
}

['/v1/users/:id'; get]
fn (mut app App) handle_get_user(id string) vweb.Result {
	mut user := app.users_find_by_id(id) or { return app.not_found() }

	return app.json(user.to_dto())
}


['/v1/users/:id'; put]
fn (mut app App) handle_update_user(id string) vweb.Result {
	data := json.decode(CreateUserDto, app.req.data) or {
		app.set_status(400, '')
		return app.text('Invalid Body Json')
	}

	mut user := app.users_find_by_id(id) or { return app.not_found() }

	user.name = data.name

	app.users_update(user) or {
		app.set_status(422, '')
		return app.text('Failed to update user ${err.msg()}')
	}

	return app.ok('')
}
