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

		app.header.add(.location, '/v1/feeds/${feed.id}')
		return app.created()
	} else {
		return app.unauthorized()
	}
}

['/v1/feeds/'; get]
fn (mut app App) handle_list_feeds() vweb.Result {
	feeds := app.feeds_find_many()
	return app.json(feeds.to_dto())
}

['/v1/feeds/next-to-fetch'; get]
fn (mut app App) handle_get_next_to_fetch() vweb.Result {
	next := app.feeds_find_next_to_fetch() or { return app.not_found() }
	return app.json(next.to_dto())
}

struct Test{
	name string
}

['/v1/feeds/:id/fetch'; post]
fn (mut app App) handle_fetch_feed(feed_id string) vweb.Result {
	if user := app.user {
		feed := app.feeds_find_by_id(feed_id) or { return app.not_found() }
		if feed.user_id != user.id {
			return app.unauthorized()
		}

		app.feeds_fetch(feed) or { return app.error(400, {
			'error': 'Unable to mark feed as fetched (${err.msg()})'
		}) }

		return app.ok('')
	} else {
		return app.unauthorized()
	}
}

['/v1/feeds/:id/follow'; post]
fn (mut app App) handle_follow_feed(feed_id string) vweb.Result {
	if user := app.user {
		ff := FeedFollow.new(user.id, feed_id)
		app.feed_follows_insert(ff) or {
			return app.error(400, {
				'error': 'Unable to follow feed (${err.msg()})'
			})
		}
		return app.created()
	} else {
		return app.unauthorized()
	}
}

['/v1/feeds/:id/follow'; delete]
fn (mut app App) handle_unfollow_feed(feed_id string) vweb.Result {
	if _ := app.user {
		ff := app.feed_follows_find_by_feed_id(feed_id) or {
			return app.error(404, {
				'error': 'Unable to unfollow feed (Not following this feed)'
			})
		}
		app.feed_follows_delete(ff.id) or {
			return app.error(400, {
				'error': 'Unable to unfollow feed (${err.msg()})'
			})
		}

		return app.ok('')
	} else {
		return app.unauthorized()
	}
}
