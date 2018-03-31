EXTENSION = lunardate		 # the extensions name
DATA = lunardate--0.0.1.sql  # script files to install
REGRESS = lunardate_test     # our test script file (without extension)
MODULES = lunardate          # our c module file to build

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
