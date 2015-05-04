all: test

test: unit functional

clean:
	-@rm builds.db

migrate:
	alembic upgrade head

run: clean migrate
	DISABLE_NOTIFICATIONS='yes' BUILDBOT_BASE_URL=http://localhost:8010 tumbler run --port=5000 quietness/routes.py --templates-path=`pwd`/templates --static-path=`pwd`/quietness/static

unit:
	nosetests -v -s --rednose --with-coverage --cover-erase --cover-package=quietness tests/unit

functional:
	nosetests --stop --logging-level=INFO -v -s --with-coverage --cover-erase --cover-package=quietness --rednose tests/functional


deploy:
	git sync
	floresta vpcs/quietness.yml --yes --inventory-path="inventory" --ansible -vvvv --tags=refresh -M library -u ubuntu --extra-vars='{"github_token":"$(GITHUB_TOKEN)"}'
