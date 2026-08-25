FROM postgres:16

# Install build dependencies (if compiling C code)
RUN apt-get update && apt-get install -y \
    build-essential \
    postgresql-server-dev-16 \
    && rm -rf /var/lib/apt/lists/*

# Copy your source code into the image
WORKDIR /usr/src/app
COPY . .

# Build and install using PGXS
RUN make && make install

EXPOSE 5432

# (Optional) Run CREATE EXTENSION on database initialization
COPY sql/init.sql /docker-entrypoint-initdb.d/