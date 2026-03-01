install:
	./scripts/installers/install.sh

test:
	python3 -m unittest discover tests

run:
	python3 src/cli/tui.py

clean-user-config:
	@chmod +x scripts/clean_user_config.sh
	@./scripts/clean_user_config.sh
