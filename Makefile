SHELL = /bin/bash
.SUFFIXES:

-include config.mk

name = idealize
version ?= 0.12.2
release ?= 2016-07-05
database = $(name)
environment ?= development

munge  = m4
munge += -D_NAME='$(name)'
munge += -D_VERSION='$(version)'
munge += -D_RELEASE='$(release)'
munge += -D_ENVIRONMENT='$(environment)'

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
	bash tools/table.sh -c -v$(version) $(table)

# make db.create
db.create:
	bash tools/run-script.sh -e $(environment) db/create.sql $(database)_index $(database)_data

# make db.create.version version=0.1.0
db.create.version:
	bash tools/run-script.sh -e $(environment) db/v$(version)/create.sql $(database)_index $(database)_data

db.drop:
	bash tools/run-script.sh -e $(environment) db/drop.sql

# make db.drop.version version=0.1.0
db.drop.version:
	bash tools/run-script.sh -e $(environment) db/v$(version)/drop.sql

db.bootstrap:
	bash tools/run-script.sh -e $(environment) db/v$(version)/bootstrap.sql
	bash tools/run-script.sh -e $(environment) db/v$(version)/bootstrap.rb

db.hotfix:
	bash tools/run-script.sh -e $(environment) db/v$(version)/hotfix.rb

clean:
	rm -f lib/prodam/idealize/version.rb

check:
	bash tools/run-script.sh test/all.rb

upgrade: clean install version db.create.version db.bootstrap db.hotfix

downgrade: clean version db.drop.version
