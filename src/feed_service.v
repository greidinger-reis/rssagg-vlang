module main

import xml
import time
import net.http

fn (mut app App) feeds_insert(f Feed) ! {
	sql app.db {
		insert f into Feed
	} or {
		if err.msg().contains('feed.url') {
			return error('Feed with this URL already exists')
		}

		return err
	}
}

fn (mut app App) feeds_find_by_id(id string) ?&Feed {
	f_list := sql app.db {
		select from Feed where id == id limit 1
	} or { [] }

	if f_list.len < 1 {
		return none
	}

	return &f_list[0]
}

fn (mut app App) feeds_find_many() []Feed {
	return sql app.db {
		select from Feed
	} or { [] }
}

fn (mut app App) feeds_find_next_to_fetch() ?&Feed {
	f_list := sql app.db {
		select from Feed order by last_fetch limit 1
	} or { [] }

	if f_list.len < 1 {
		return none
	}

	return &f_list[0]
}

fn (mut app App) feeds_fetch(f &Feed) ! {
	res := http.get(f.url)!
	doc := xml.XMLDocument.from_string(res.body)!
	dump(doc)

	sql app.db {
		update Feed set last_fetch = time.now(), last_fetch = time.now() where id == f.id
	}!
}

fn (mut app App) feed_follows_insert(ff FeedFollow) ! {
	sql app.db {
		insert ff into FeedFollow
	} or {
		if err.msg().contains('feed_follow.follow_uniqueness') {
			return error('Already following this feed')
		}

		return err
	}
}

fn (mut app App) feed_follows_find_many() []FeedFollow {
	return sql app.db {
		select from FeedFollow
	} or { [] }
}

fn (mut app App) feed_follows_find_by_feed_id(feed_id string) ?&FeedFollow {
	ff_list := sql app.db {
		select from FeedFollow where feed_id == feed_id limit 1
	} or { [] }

	if ff_list.len < 1 {
		return none
	}

	return &ff_list[0]
}

fn (mut app App) feed_follows_delete(id string) ! {
	sql app.db {
		delete from FeedFollow where id == id
	}!
}
