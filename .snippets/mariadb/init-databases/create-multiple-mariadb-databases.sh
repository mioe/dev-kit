#!/bin/bash
set -euo pipefail

create_database() {
  local db="$1"
  echo "  -> creating database '$db' and granting access to '$MARIADB_USER'"
  mariadb -u root -p"$MARIADB_ROOT_PASSWORD" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`$db\`
      CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    GRANT ALL PRIVILEGES ON \`$db\`.* TO '$MARIADB_USER'@'%';
EOSQL
}

if [ -n "${MARIADB_MULTIPLE_DATABASES:-}" ]; then
  echo "Multiple database creation requested: $MARIADB_MULTIPLE_DATABASES"
  for db in $(echo "$MARIADB_MULTIPLE_DATABASES" | tr ',' ' '); do
    create_database "$db"
  done
  mariadb -u root -p"$MARIADB_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
  echo "Multiple databases created"
fi
