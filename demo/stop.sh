#!/bin/sh 

# Set default value for DATABASE_TYPE
DATABASE_TYPE="${DATABASE_TYPE:-SqlServer}"

# Convert DATABASE_TYPE to lowercase for case insensitive comparison
DATABASE_TYPE_LOWER=$(echo "$DATABASE_TYPE" | tr '[:upper:]' '[:lower:]')

# Check if the command line parameter --useMariaDb is provided, case insensitive
for arg in "$@"; do
    arg_lower=$(echo "$arg" | tr '[:upper:]' '[:lower:]')
    if [ "$arg_lower" == "--usemariadb" ]; then
        DATABASE_TYPE_LOWER="mariadb"
    fi
done

# Determine which Docker Compose file to use
if [ "$DATABASE_TYPE_LOWER" == "mariadb" ]; then
    DOTNET_COMPOSE_FILE="docker-compose-demo-dotnet-mariadb.yml"
else
    DOTNET_COMPOSE_FILE="docker-compose-demo-dotnet.yml"
    DATABASE_TYPE_LOWER="sqlserver"
fi

echo "SQL Database type set to ["$DATABASE_TYPE_LOWER"]."
echo "Stopping docker containers ..."

docker compose -f docker-compose-demo-js.yml -f $DOTNET_COMPOSE_FILE -f docker-compose-demo-keycloak.yml -f docker-compose-demo-kong.yml down

echo "Docker containers stopped."
