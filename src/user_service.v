module main

import time

fn (mut app App) users_insert(u User) ! {
	sql app.db {
		insert u into User
	}!
}

fn (mut app App) users_find_many(limit int, offset int) []User {
	return sql app.db {
		select from User limit limit offset offset
	} or { return [] }
}

fn (mut app App) users_find_by_id(id string) ?&User {
	list := sql app.db {
		select from User where id == id
	} or { [] }

	if list.len == 0 {
		return none
	}

	return &list[0]
}

fn (mut app App) users_delete(u User) ! {
	sql app.db {
		delete from User where id == u.id
	}!
}

fn (mut app App) users_update(u User) ! {
	sql app.db {
		update User set name = u.name, updated_at = time.now() where id == u.id
	}!
}
