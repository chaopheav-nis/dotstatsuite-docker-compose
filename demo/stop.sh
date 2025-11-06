#!/bin/sh 

DOTNET_COMPOSE_FILE="docker-compose-demo-dotnet.yml"

echo "Stopping docker containers ..."

docker compose -f docker-compose-demo-js.yml -f $DOTNET_COMPOSE_FILE -f docker-compose-demo-keycloak.yml down

echo "Docker containers stopped."
