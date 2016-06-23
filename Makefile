SHELL = /bin/bash
.SUFFIXES:

name = idealize
version ?= 0.9.1
release ?= 2016-06-23
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
	exec $(bundle) exec pry -Ilib:app -r prodam/idealize -e 'include Prodam::Idealize'

# make server environment=[development]
server.start: version
	exec $(bundle) exec puma

server.stop:
	exec $(bundle) exec pumactl --pidfile tmp/$(environment).pid stop

server.restart: server.stop server.start

# make db.console environment=[development]
db.console:
	exec rlwrap sqlplus $$(cat db/$(environment).ora)

# make db.table version=[version] table=[table]
db.table:
	sh db/table.sh -c -v$(version) $(table)

# make db.create
db.create:
	sh db/sqlrun.sh -e $(environment) db/create.sql $(database)_index $(database)_data

# make db.create.version version=0.1.0
db.create.version:
	sh db/sqlrun.sh -e $(environment) db/v$(version)/create.sql $(database)_index $(database)_data

db.drop:
	sh db/sqlrun.sh -e $(environment) db/drop.sql

# make db.drop.version version=0.1.0
db.drop.version:
	sh db/sqlrun.sh -e $(environment) db/v$(version)/drop.sql

db.bootstrap:
	test -f db/v$(version)/bootstrap.sql && sh db/sqlrun.sh -e $(environment) db/v$(version)/bootstrap.sql || true
	test -f db/v$(version)/bootstrap.rb  && ruby -Ilib:app db/v$(version)/bootstrap.rb || true

db.hotfix:
	test -f db/v$(version)/hotfix.rb  && ruby -Ilib:app db/v$(version)/hotfix.rb || true

clean:
	rm -f lib/prodam/idealize/version.rb

check:
	ruby test/all.rb

