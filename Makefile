name = idealize
version ?= 0.1.0
database = $(name)
environment ?= development

all: check

install: install.libraries install.vendors

install.libraries:
	bundle install

install.vendors:
	git clone --depth 10 https://github.com/google/material-design-lite.git vendors/mdl

database.table:
	sh db/table.sh -v$(version) $(table)

database.create:
	sh db/sqlrun.sh db/create.sql $(database)_index $(database)_data

database.create.version:
	sh db/sqlrun.sh db/v$(version)/create.sql $(database)_index $(database)_data

database.drop:
	sh db/sqlrun.sh db/drop.sql

database.drop.version:
	sh db/sqlrun.sh db/v$(version)/drop.sql

database.bootstrap:
	sh db/sqlrun.sh db/bootstrap.sql

check:
	ruby test/all.rb

server:
	puma --environment $(environment) --port 8092

