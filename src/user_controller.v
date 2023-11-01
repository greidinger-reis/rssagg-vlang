module main

import json
import vweb

struct CreateUserDto {
	name string [required]
}

['/v1/users'; post]
fn (mut app App) handle_create_user() vweb.Result {
	data := json.decode(CreateUserDto, app.req.data) or {
		app.set_status(400, '')
		return app.text('Invalid Body Json')
	}

	user := User.new(data.name)

	app.users_insert(user) or {
		app.set_status(422, '')
		return app.text('Failed to insert user ${err.msg()}')
	}

	app.set_status(201, '')
	return app.json(user.to_dto())
}

['/v1/users'; get]
fn (mut app App) handle_get_user_info() vweb.Result {
	if user := app.user {
		return app.json(user.to_dto())
	} else {
		app.set_status(401, '')
		return app.text('')
	}
}

['/v1/users'; put]
fn (mut app App) handle_update_user() vweb.Result {
	data := json.decode(CreateUserDto, app.req.data) or {
		app.set_status(400, '')
		return app.text('Invalid Body Json')
	}

	if mut user := app.user {
		user.name = data.name
		app.users_update(user) or {
			app.set_status(422, '')
			return app.text('Failed to update user ${err.msg()}')
		}

		return app.ok('')
	} else {
		app.set_status(401, '')
		return app.text('')
	}
}
