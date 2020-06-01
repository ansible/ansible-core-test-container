.PHONY: build update freeze

build:
	docker build -t ansible-base-test-container .

update:
	./update.py

freeze:
	./freeze.sh
