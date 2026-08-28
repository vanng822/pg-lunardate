EXTENSION = lunardate		 # the extensions name
DATA = lunardate--0.0.1.sql  # script files to install
REGRESS = lunardate_test     # our test script file (without extension)
MODULES = lunardate          # our c module file to build

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

TEST_IMAGE = pg-lunardate:test

.PHONY: test
test:
	docker build --tag $(TEST_IMAGE) .
	@set -eu; \
	container_id=$$(docker run --detach --env POSTGRES_PASSWORD=postgres $(TEST_IMAGE)); \
	cleanup() { docker rm --force "$$container_id" >/dev/null 2>&1 || true; }; \
	trap cleanup EXIT; \
	until docker exec "$$container_id" pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done; \
	docker exec "$$container_id" chmod -R a+rwX /usr/src/app; \
	docker exec --user postgres "$$container_id" make installcheck || { \
		echo "=== TEST FAILURE DETECTED: regression.diffs ==="; \
		docker exec --user postgres "$$container_id" cat /usr/src/app/regression.diffs 2>/dev/null || \
		docker exec --user postgres "$$container_id" find /usr/src/app -name "regression.diffs" -exec cat {} +; \
		exit 1; \
	}
