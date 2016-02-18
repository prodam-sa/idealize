name = idealize
version ?= 0.1.0
database = $(name)
environment ?= development

all: check

install: app.libraries app.vendors

app.libraries:
	bundle install

app.vendors:
	git clone --depth 10 https://github.com/google/material-design-lite.git vendors/mdl

app.console:
	exec ruby -S pry -Ilib:app -r console

# make db.console environment=production
db.console:
	exec rlwrap sqlplus $$(cat db/$(environment).ora)

# make db.table version=0.1.0 table=TABELA
db.table:
	sh db/table.sh -v$(version) $(table)

# make db.create
db.create:
	sh db/sqlrun.sh db/create.sql $(database)_index $(database)_data

# make db.create.version version=0.1.0
db.create.version:
	sh db/sqlrun.sh db/v$(version)/create.sql $(database)_index $(database)_data

db.drop:
	sh db/sqlrun.sh db/drop.sql

# make db.drop.version version=0.1.0
db.drop.version:
	sh db/sqlrun.sh db/v$(version)/drop.sql

db.bootstrap:
	sh db/sqlrun.sh db/bootstrap.sql

check:
	ruby test/all.rb

# make server environment=production
server:
	ruby -S puma --environment $(environment) --port 8092

