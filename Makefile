SHELL = /bin/bash
.SUFFIXES:

name = idealize
version ?= 0.5.0
release ?= 2016-05-18
database = $(name)
environment ?= development

munge  = m4
munge += -D_NAME='$(name)'
munge += -D_VERSION='$(version)'
munge += -D_RELEASE='$(release)'

bundle = ruby -S bundle

.SUFFIXES: .m4 .rb

all: check

.m4.rb:
	$(munge) $(<) > $(@)

install: install.libraries

install.libraries:
	$(bundle) install
	bower install

version: lib/prodam/$(name)/version.rb

console: version
	exec $(bundle) exec pry -Ilib:app -r prodam/idealize

# make server environment=production
server.start: version
	exec $(bundle) exec puma

server.stop:
	exec $(bundle) exec pumactl --pidfile tmp/$(environment).pid stop

server.restart: server.stop server.start

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
	test -f db/v$(version)/bootstrap.sql && sh db/sqlrun.sh db/v$(version)/bootstrap.sql || true
	test -f db/v$(version)/bootstrap.rb  && ruby -Ilib:app db/v$(version)/bootstrap.rb || true

clean:
	rm -f lib/prodam/idealize/version.rb

check:
	ruby test/all.rb

