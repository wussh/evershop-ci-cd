#!/bin/sh
set -e

# Default to 'database' service if not provided
DB_HOST=${DB_HOST:-database}
DB_PORT=${DB_PORT:-5432}

echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
# Loop until postgres is reachable
while ! nc -z "$DB_HOST" "$DB_PORT"; do
  echo "Postgres is unavailable - retrying in 1s..."
  sleep 1
done

echo "Postgres is up - starting EverShop"

# Execute the container's main command
exec "$@"