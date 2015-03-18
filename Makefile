all: test

test: unit functional

clean:
	-@rm builds.db

migrate:
	alembic upgrade head

run: clean migrate
	DISABLE_NOTIFICATIONS='yes' BUILDBOT_BASE_URL=http://localhost:8010 tumbler run --port=5000 timeless/routes.py --templates-path=`pwd`/templates --static-path=`pwd`/timeless/static

unit:
	nosetests -v -s --rednose --with-coverage --cover-erase --cover-package=timeless tests/unit

functional:
	nosetests --stop --logging-level=INFO -v -s --with-coverage --cover-erase --cover-package=timeless --rednose tests/functional


deploy:
	git sync
	floresta vpcs/timeless.yml --yes --inventory-path="inventory" --ansible -vvvv --tags=refresh -M library -u ubuntu --extra-vars='{"github_token":"$(GITHUB_TOKEN)"}'
