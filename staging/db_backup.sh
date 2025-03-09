#!/bin/bash

if [[ -z "$STACK_NAME" || -z "$SERVICE_NAME" || -z "$POSTGRES_USER" || -z "$POSTGRES_DB" || -z "$POSTGRES_PASSWORD" || -z "$BACKUP_DIR" ]]; then
    echo "Error: Required environment variables are not set!"
    echo "Ensure STACK_NAME, SERVICE_NAME, POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, and BACKUP_DIR are defined."
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

CONTAINER_ID=$(docker ps --filter "name=${STACK_NAME}_${SERVICE_NAME}" --format "{{.ID}}" | head -n 1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No running container found for ${STACK_NAME}_${SERVICE_NAME}!"
    exit 1
fi

echo "Using container ID: $CONTAINER_ID"

BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql"

echo "Backing up database to: $BACKUP_FILE"

# Use PGPASSWORD to pass the database password
docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" "$CONTAINER_ID" pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"
else
    echo "Backup failed!"
    exit 1
fi
