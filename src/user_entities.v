module main

import time
import rand
import encoding.base64
import crypto.sha256

[noinit]
struct User {
pub mut:
	id         string    [primary]
	name       string
	api_key    string    [unique]
	created_at time.Time 
	updated_at time.Time
}

fn User.new(name string) &User {
	api_key := base64.encode(sha256.hexhash(rand.string(32)).bytes())

	return &User{
		id: rand.uuid_v4()
		name: name
		created_at: time.now()
		updated_at: time.now()
		api_key: api_key
	}
}

fn (u &User) to_dto() &UserDto {
	return &UserDto{
		id: u.id
		name: u.name
		created_at: u.created_at.str()
		updated_at: u.updated_at.str()
		api_key: u.api_key
	}
}

fn (u []User) to_dto() []UserDto {
	return u.map(*it.to_dto())
}

struct UserDto {
pub mut:
	id         string
	name       string
	api_key    string [json: 'apiKey']
	created_at string [json: 'createdAt']
	updated_at string [json: 'updatedAt']
}
