.PHONY: all build/trello.svg

all: build/trello.svg

build/trello.svg:
	ruby digraph.rb > $@
