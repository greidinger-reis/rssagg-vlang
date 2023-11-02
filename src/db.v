module main

import db.sqlite
import db.pg
import os

type Connection = pg.DB | sqlite.DB

const (
	sqlite_filename = 'db.sqlite'
	pg_port         = os.getenv('PG_PORT').int()
	pg_dbname       = os.getenv('PG_DBNAME')
	pg_host         = os.getenv('PG_HOST')
	pg_user         = os.getenv('PG_USER')
	pg_password     = os.getenv('PG_PASSWORD')
)

fn create_db_sqlite() sqlite.DB {
	return sqlite.connect(sqlite_filename) or { panic('Could not connect to sqlite') }
}

fn create_db_pg() pg.DB {
	return pg.connect(
		port: pg_port
		dbname: pg_dbname
		host: pg_host
		password: pg_host
		user: pg_user
	) or { panic('Could not connect to pg') }
}
