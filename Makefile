.PHONY: build update freeze

build:
	docker build -t ansible-core-test-container .

update:
	./update.py

freeze:
	./freeze.sh
