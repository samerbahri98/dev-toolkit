#!/bin/bash

set -e

# Create superuser if data folder is empty or db not initialized
if [ ! -f /app/pb/pb_data/data.db ]; then
    echo "Initializing superuser..."
    /app/pocketbase --dir=/app/pb/pb_data superuser upsert $PB_EMAIL $PB_PASSWORD
fi

exec /app/pocketbase serve \
    --http=0.0.0.0:8080 \
    --dir=/app/pb/pb_data \
    --hooksDir=/app/pb/hooks \
    --publicDir=/app/pb/public \
    --migrationsDir=/app/pb/migrations \
    --automigrate \
    --encryptionEnv=PB_ENCRYPT
