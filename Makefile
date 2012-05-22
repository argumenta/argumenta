COFFEE_PATHS = *.coffee config lib routes

all: build

build: coffee

coffee:
	coffee -c $(COFFEE_PATHS)

clean: clean_coffee

clean_coffee:
	-find $(COFFEE_PATHS) -name '*.coffee' | sed 's/.coffee$$/.js/' | xargs rm

.PHONY: all build coffee clean clean_coffee
