module main

import time
import rand

[table: 'feed']
[noinit]
struct Feed {
	id         string    [primary]
	name       string
	url        string    [unique]
	user_id    string    [references: 'user(id)']
	created_at time.Time
	updated_at time.Time
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
	created_at string [json: 'createdAt']
	updated_at string [json: 'updatedAt']
}
