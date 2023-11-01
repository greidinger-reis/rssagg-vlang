module main

import vweb
import net.http

const (
	auth_header_name = 'Authorization'
)

[inline]
fn extract_api_key_from_headers(headers http.Header) !string {
	auth_header := headers.get_custom(auth_header_name)!
	split := auth_header.split(' ')

	if split.len != 2 {
		return error('Invalid auth header')
	}

	if split[0] != 'Api-Key' {
		return error('Invalid auth header')
	}

	return split[1]
}

fn (mut app App) get_current_user() ?&User {
	api_key := extract_api_key_from_headers(app.req.header) or { return none }
	user := app.users_find_by_api_key(api_key) or { return none }
	return user
}

fn (mut app App) unauthorized() vweb.Result {
	app.set_status(401, '')
	return app.text('')
}
