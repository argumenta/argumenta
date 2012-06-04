COFFEE_PATHS := app config lib test
TEST_PATHS := test

TESTS := $(shell find $(TEST_PATHS) -name '*.js')

all: build

build: coffee

coffee:
	coffee -c $(COFFEE_PATHS)

coffee_forever:
	coffee -c -w $(COFFEE_PATHS) &

test:
	NODE_ENV=testing ./node_modules/.bin/mocha $(TESTS)

test_forever:
	NODE_ENV=testing ./node_modules/.bin/mocha -w $(TESTS) &

clean: clean_coffee

clean_coffee:
	-find $(COFFEE_PATHS) -name '*.coffee' | sed 's/.coffee$$/.js/' | xargs rm

.PHONY: all build coffee coffee_forever test test_forever clean clean_coffee
