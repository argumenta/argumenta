COFFEE_PATHS := app config lib routes test
DOC_SOURCES := lib
TEST_PATHS := test
TESTS ?= $(shell find $(TEST_PATHS) -name '*.coffee' | sed 's/coffee$$/js/')
REPORTER ?= spec
BCRYPT_COST ?= 1

all: build docs

build: server client

server: coffee

coffee:
	coffee -c $(COFFEE_PATHS)

coffee_forever:
	@coffee -c -w $(COFFEE_PATHS) &

client:
	mkdir -p build/client
	./node_modules/.bin/browserify lib/argumenta/objects/index.coffee \
		--debug --exports require -o build/client/objects.js

docs: docco sweeten-docco

docco:
	find $(DOC_SOURCES) -name '*.coffee' | xargs docco

sweeten-docco:
	./node_modules/.bin/sweeten-docco

test: coffee
	NODE_ENV=testing BCRYPT_COST=$(BCRYPT_COST) \
		./node_modules/.bin/mocha $(TESTS)

test_forever: coffee_forever
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

clean: clean_build clean_coffee clean_docs

clean_build:
	-rm -rf build

clean_coffee:
	-find $(COFFEE_PATHS) -name '*.coffee' | sed 's/.coffee$$/.js/' | xargs rm

clean_docs:
	-rm -rf docs

.PHONY: all build server client coffee coffee_forever test test_forever clean clean_build clean_coffee clean_docs
