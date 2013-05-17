COFFEE := ./node_modules/.bin/coffee
COFFEE_PATHS := app config db lib routes test
DOC_SOURCES := lib
TEST_PATHS := test
TESTS ?= $(shell find $(TEST_PATHS) -name '*.coffee' | sed 's/coffee$$/js/')
REPORTER ?= spec
BCRYPT_COST ?= 1

all: build docs

build: server client production gzip

production:
	ln -sf -T '../../build/client/objects.js' public/javascripts/objects.js
	ln -sf -T '../node_modules/argumenta-widgets/production' public/widgets

development:
	ln -sf -T '../../build/client/objects.js' public/javascripts/objects.js
	ln -sf -T '../node_modules/argumenta-widgets/development' public/widgets

server: coffee stylus

coffee:
	coffee -c $(COFFEE_PATHS)

coffee_forever:
	@coffee -c -w $(COFFEE_PATHS) &

stylus:
	./node_modules/.bin/stylus --use ./node_modules/nib public/stylesheets

client:
	mkdir -p build/client
	./node_modules/.bin/browserify lib/argumenta/objects/index.coffee \
		--debug --exports require -o build/client/objects.js

gzip:
	cd public; \
	GZIP='gzip -9 -c "$$1" > "$${1}.gz"'; \
	find -L . -type f -not -name '*.gz' -exec bash -c "$$GZIP" GZIP '{}' \;

docs: api_doc source_doc

api_doc:
	$(COFFEE) ./bin/build-api-doc.coffee

source_doc: docco sweeten-docco

docco:
	find $(DOC_SOURCES) -name '*.coffee' | xargs docco

sweeten-docco:
	./node_modules/.bin/sweeten-docco

test: build
	NODE_ENV=testing BCRYPT_COST=$(BCRYPT_COST) \
		./node_modules/.bin/mocha $(TESTS)

test_forever: build coffee_forever
	@while inotifywait -e close_write -r $(COFFEE_PATHS); do sleep 1; \
		NODE_ENV=testing BCRYPT_COST=$(BCRYPT_COST) \
			./node_modules/.bin/mocha $(TESTS) -R $(REPORTER); \
	done

archive:
	PROJ=`basename $$(pwd)` DATE=`date +%Y.%m.%d` ; \
	cd .. ; \
	tar cvJf "$${PROJ}-$${DATE}.tar.xz" \
		--exclude=node_modules \
		--transform "s#^#$${PROJ}-$${DATE}/#" \
		"$$PROJ"

clean: clean_build clean_coffee clean_gzip clean_docs

clean_build:
	-rm -rf build

clean_coffee:
	-find $(COFFEE_PATHS) -name '*.coffee' | sed 's/.coffee$$/.js/' | xargs rm

clean_gzip:
	-find public -type f -name '*.gz' | xargs rm

clean_docs:
	-rm -rf docs

.PHONY: all build production development server client coffee coffee_forever stylus gzip api_doc source_doc test test_forever clean clean_build clean_coffee clean_gzip clean_docs
