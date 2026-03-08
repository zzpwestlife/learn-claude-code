# Union Search Skill Makefile
PYTHON := python3
PIP := pip3
SKILL_DIR := $(shell pwd)
ENV_FILE := .env
ENV_EXAMPLE := .env.example

# Default query and platform for testing
Q ?= AI Agent
P ?=

.PHONY: help install setup search test clean check-env

help:
	@echo "Union Search Skill - Available commands:"
	@echo "  make install    - Install Python dependencies"
	@echo "  make setup      - Create .env configuration file"
	@echo "  make search     - Run a search (usage: make search Q='query' [P='platform'])"
	@echo "                    Example: make search Q='Python tutorial' P='duckduckgo'"
	@echo "  make clean      - Clean up temporary files"
	@echo "  make test       - Run a test search (Brave)"

install:
	$(PYTHON) -m pip install requests python-dotenv lxml pyimagedl curl_cffi tavily-python feedparser pygments

setup:
	@if [ ! -f $(ENV_FILE) ]; then \
		cp $(ENV_EXAMPLE) $(ENV_FILE); \
		echo "Created $(ENV_FILE) from example. Please edit it to add your API keys."; \
	else \
		echo "$(ENV_FILE) already exists. No changes made."; \
	fi

check-env:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "Warning: .env file not found. Run 'make setup' first."; \
	fi

search: check-env
	@if [ -z "$(Q)" ]; then \
		echo "Error: Please provide a query using Q='your query'"; \
		exit 1; \
	fi
	@if [ -z "$(P)" ]; then \
		$(PYTHON) union_search_cli.py search "$(Q)" --limit 3 --pretty; \
	else \
		$(PYTHON) union_search_cli.py $(P) "$(Q)" --limit 3 --pretty; \
	fi

test: check-env
	@echo "Testing Brave search..."
	$(PYTHON) union_search_cli.py brave "AI Agent" --limit 1 --pretty || echo "Brave search failed (check network/proxy)"

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
