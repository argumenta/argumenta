COFFEE_PATHS := app config lib routes test
DOC_SOURCES := lib
TEST_PATHS := test
TESTS := $(shell find $(TEST_PATHS) -name '*.coffee' | sed 's/coffee$$/js/')

all: build docs

build: coffee

coffee:
	coffee -c $(COFFEE_PATHS)

coffee_forever:
	coffee -c -w $(COFFEE_PATHS) &

docs: docco sweeten-docco

docco:
	find $(DOC_SOURCES) -name '*.coffee' | xargs docco

sweeten-docco:
	./node_modules/.bin/sweeten-docco

test: coffee
	NODE_ENV=testing ./node_modules/.bin/mocha $(TESTS)

test_forever:
	NODE_ENV=testing ./node_modules/.bin/mocha -w $(TESTS) &

clean: clean_coffee clean_docs

clean_coffee:
	-find $(COFFEE_PATHS) -name '*.coffee' | sed 's/.coffee$$/.js/' | xargs rm

clean_docs:
	-rm -rf docs

.PHONY: all build coffee coffee_forever test test_forever clean clean_coffee clean_docs
