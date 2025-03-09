#!/bin/bash

if [[ -z "$STACK_NAME" || -z "$SERVICE_NAME" || -z "$POSTGRES_USER" || -z "$POSTGRES_DB" || -z "$POSTGRES_PASSWORD" || -z "$BACKUP_DIR" ]]; then
    echo "Error: Required environment variables are not set!"
    echo "Ensure STACK_NAME, SERVICE_NAME, POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, and BACKUP_DIR are defined."
    exit 1
fi

CONTAINER_ID=$(docker ps --filter "name=${STACK_NAME}_${SERVICE_NAME}" --format "{{.ID}}" | head -n 1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No running container found for ${STACK_NAME}_${SERVICE_NAME}!"
    exit 1
fi

echo "Resetting database $POSTGRES_DB..."

# Use PGPASSWORD to pass the password for PostgreSQL commands
docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" -i "$CONTAINER_ID" psql -U "$POSTGRES_USER" -d postgres <<EOF
DROP DATABASE IF EXISTS $POSTGRES_DB;
CREATE DATABASE $POSTGRES_DB;
EOF

echo "Database $POSTGRES_DB has been reset."

BACKUP_FILE=$(ls -t "$BACKUP_DIR"/backup_*.sql 2>/dev/null | head -n 1)

if [ -f "$BACKUP_FILE" ]; then
    echo "Restoring from latest backup: $BACKUP_FILE"
    # Use PGPASSWORD to pass the password for PostgreSQL commands when restoring
    docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" -i "$CONTAINER_ID" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$BACKUP_FILE"
    echo "Restore complete."
else
    echo "No backup file found. Skipping restore."
fi
