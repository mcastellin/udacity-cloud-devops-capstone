setup:
	# Creates a Python virtual environment
	python3 -m venv ~/.capstone

install:
	# Upgrades pip and install all requirements
	@. ~/.capstone/bin/activate &&\
		pip install --upgrade pip &&\
		pip install -r requirements.txt

lint:
	# Run linting on all python files in application
	@source ~/.capstone/bin/activate &&\
		pylint --disable=R,C api/*.py

run-dev:
	# Runs the python api main file
	# Useful for development
	@source ~/.capstone/bin/activate &&\
		python api/app.py

all: install lint
