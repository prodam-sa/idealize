name = idealize
version ?= 0.1.0
database = $(name)
environment ?= development

vendors  = material-design-lite dialog-polyfill requirejs
vendors += scribe
vendors += scribe-plugin-blockquote-command
vendors += scribe-plugin-code-command
vendors += scribe-plugin-content-cleaner
vendors += scribe-plugin-curly-quotes
vendors += scribe-plugin-formatter-plain-text-convert-new-lines-to-html
vendors += scribe-plugin-heading-command
vendors += scribe-plugin-intelligent-unlink-command
vendors += scribe-plugin-keyboard-shortcuts
vendors += scribe-plugin-link-prompt-command
vendors += scribe-plugin-sanitizer
vendors += scribe-plugin-smart-lists
vendors += scribe-plugin-toolbar

$(vendors):
	bower install $(@) --save

all: check

install: app.libraries app.vendors

app.libraries:
	bundle install

app.vendors: $(vendors)

app.console:
	exec ruby -S pry -Ilib:app -r prodam/idealize

# make app.server environment=production
app.server:
	ruby -S puma --environment $(environment) --port 8091 --debug --log-requests --daemon

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
	ruby -Ilib:app db/bootstrap.rb

check:
	ruby test/all.rb

