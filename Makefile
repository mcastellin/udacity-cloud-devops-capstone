setup:
	# Creates a Python virtual environment
	python3 -m venv ~/.capstone

install:
	source ~/.capstone/bin/activate &&\
		pip install --upgrade pip &&\
		pip install -r requirements.txt

lint:
	pylint --disable=R,C api/*.py

run-dev:
	source ~/.capstone/bin/activate &&\
		python api/app.py

all: install lint
