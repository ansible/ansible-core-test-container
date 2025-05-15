.PHONY: build
build:
	podman build -t ansible-core-test-container .

.PHONY: update
update:
	./update.py

.PHONY: freeze
freeze:
	./freeze.py ansible-core-test-container-freezer
