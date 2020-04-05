setup:
	# Creates a Python virtual environment
	python3 -m venv ~/.capstone

install:
	# Upgrades pip and install all requirements
	@. ~/.capstone/bin/activate &&\
		pip install --upgrade pip &&\
		pip install -r api/requirements.txt

lint-python:
	# Run linting on all python files
	@. ~/.capstone/bin/activate &&\
		pylint --disable=R,C api/*.py

lint-docker:
	# Lint Dockerfiles
	@hadolint **/Dockerfile

lint-html: 
	# Lint HTML files
	@find . -name '*.html' -exec tidy -q -e {} +

test:
	# Testing python application
	echo "good"

run-dev:
	# Runs the python api main file
	# Useful for development
	@. ~/.capstone/bin/activate &&\
		python api/app.py

lint: lint-python lint-docker lint-html

all: install lint
