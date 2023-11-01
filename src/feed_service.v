module main

fn (mut app App) feeds_insert(f Feed) ! {
	sql app.db {
		insert f into Feed
	}!
}
