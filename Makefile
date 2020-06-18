ORGANISATION=scratch-map
GIT_BRANCH?=$(shell git rev-parse --abbrev-ref HEAD)
SNYK_TOKEN?=
SONAR_TOKEN?=

init:
	pip install pipenv --upgrade
	pipenv install --dev
	pre-commit install

install-dev:
	pipenv install --dev

install:
	pipenv install

lint:
	pipenv run flake8
	pipenv check ./scratch-map ./tests

snykauth:
	# Login to snyk
	snyk auth $(SNYK_TOKEN)

snyktest: snykauth
	# Check the dependencies for vulnerabilities
	snyk test --org=$(ORGANISATION)

snykmonitor: snykauth
	# Push the dependencies to snyk for ongoing monitoring/alerting of vulnerabilities
	snyk monitor --org=$(ORGANISATION)

sonarscan:
	sonar-scanner \
	  -Dsonar.organization=scratch-map \
	  -Dsonar.projectKey=scratch-map_scratch-map \
	  -Dsonar.branch.name=$(GIT_BRANCH) \
	  -Dsonar.sources=. \
	  -Dsonar.host.url=https://sonarcloud.io \
	  -Dsonar.login=$(SONAR_TOKEN)

test: lint
	pipenv run python run_tests.py

start:
	docker-compose up --no-deps

build:
	docker-compose build
