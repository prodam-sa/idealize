name = idealize
version ?= 0.0.0
database = $(name)
environment ?= development

bundle = ruby -S bundle

all: check

install: install.libraries

install.libraries:
	$(bundle) install
	bower install

app.console:
	exec $(bundle) exec pry -Ilib:app -r prodam/idealize

# make app.server environment=production
app.server.start: app.version
	exec $(bundle) exec puma

app.server.stop:
	exec $(bundle) exec pumactl --pidfile tmp/$(environment).pid stop

app.server.restart: app.server.stop app.server.start

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

check:
	ruby test/all.rb

