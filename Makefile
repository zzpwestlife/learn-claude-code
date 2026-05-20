install:
	./scripts/installers/install.sh

search-install:
	$(MAKE) -C union-search-skill install

search-setup:
	$(MAKE) -C union-search-skill setup

search-test:
	$(MAKE) -C union-search-skill test

search:
	@if [ -z "$(Q)" ]; then \
		echo "Usage: make search Q='query' [P='platform']"; \
	else \
		$(MAKE) -C union-search-skill search Q="$(Q)" P="$(P)"; \
	fi

test:
	python3 -m unittest discover tests

lint-skills:
	python3 -W ignore::RuntimeWarning scripts/lint_skills.py

lint-d8-reports:
	python3 scripts/lint_d8_reports.py

check: lint-skills lint-d8-reports test

run:
	python3 src/cli/tui.py

clean-user-config:
	@chmod +x scripts/clean_user_config.sh
	@./scripts/clean_user_config.sh
