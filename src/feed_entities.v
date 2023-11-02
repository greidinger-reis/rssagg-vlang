module main

import time
import rand

[table: 'feed']
[noinit]
struct Feed {
	id      string [primary]
	name    string
	url     string [unique]
	user_id string [references: 'user(id)']
	// Change this to a ?time.Time when Vlang ORM supports it
	last_fetch ?i64
	created_at time.Time [required]
	updated_at time.Time [required]
}

fn Feed.new(name string, url string, user_id string) &Feed {
	return &Feed{
		id: rand.uuid_v4()
		name: name
		url: url
		user_id: user_id
		created_at: time.now()
		updated_at: time.now()
	}
}

fn (f &Feed) to_dto() &FeedDto {
	return &FeedDto{
		id: f.id
		name: f.name
		url: f.url
		user_id: f.user_id
		last_fetch: if last_fetch := f.last_fetch { time.unix(i64(last_fetch)).str() } else { '' }
		created_at: f.created_at.str()
		updated_at: f.updated_at.str()
	}
}

fn (f []Feed) to_dto() []FeedDto {
	return f.map(*it.to_dto())
}

struct FeedDto {
	id         string
	name       string
	url        string
	user_id    string [json: 'userId']
	last_fetch string [json: 'lastFetch']
	created_at string [json: 'createdAt']
	updated_at string [json: 'updatedAt']
}

[table: 'feed_follow']
[noinit]
struct FeedFollow {
	// This field is to allow a composite unique constraint on user_id and feed_id; since sqlite doesn't allow alter table add constraint
	follow_uniqueness string [unique]
pub mut:
	id      string [primary]
	user_id string [sql_type: 'text not null references user(id) on delete cascade']
	feed_id string [sql_type: 'text not null references feed(id) on delete cascade']
}

fn FeedFollow.new(user_id string, feed_id string) &FeedFollow {
	return &FeedFollow{
		id: rand.uuid_v4()
		user_id: user_id
		feed_id: feed_id
		follow_uniqueness: user_id + feed_id
	}
}

fn (ff &FeedFollow) to_dto() &FeedFollowDto {
	return &FeedFollowDto{
		id: ff.id
		user_id: ff.user_id
		feed_id: ff.feed_id
	}
}

struct FeedFollowDto {
pub mut:
	id      string
	user_id string [json: 'userId']
	feed_id string [json: 'feedId']
}
