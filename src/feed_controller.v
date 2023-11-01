module main

import json
import vweb

struct CreateFeedDto {
	name string [required]
	url  string [required]
}

['/v1/feeds/'; post]
fn (mut app App) handle_create_feed() vweb.Result {
if user := app.user {
	data := json.decode(CreateFeedDto, app.req.data) or {
		return app.error(400, {
			'error': 'Malformed JSON input'
		})
	}

	feed := Feed.new(data.name, data.url, user.id)
	app.feeds_insert(feed) or {
		return app.error(400, {
			'error': 'Unable to create feed (${err.msg()})'
		})
	}

	return app.created()
} else {
	return app.unauthorized()
}}

['/v1/feeds'; get]
fn (mut app App) handle_get_all_feeds() vweb.Result {
	feeds := sql app.db {
		select from Feed
	} or { return app.error(404, {
		'error': err.msg()
	}) }

	return app.json(feeds)
}
