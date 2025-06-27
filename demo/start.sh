#!/bin/bash

# Set default value for DATABASE_TYPE
DATABASE_TYPE="${DATABASE_TYPE:-SqlServer}"

# Convert DATABASE_TYPE to lowercase for case insensitive comparison
DATABASE_TYPE_LOWER=$(echo "$DATABASE_TYPE" | tr '[:upper:]' '[:lower:]')

# Check if the command line parameter --useMariaDb is provided, case insensitive
for arg in "$@"; do
    arg_lower=$(echo "$arg" | tr '[:upper:]' '[:lower:]')
    if [ "$arg_lower" == "--usemariadb" ]; then
        DATABASE_TYPE_LOWER="mariadb"
    else
        HOST=$arg
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

##################
# Initialization #
##################
####################### HOST=$1
DIR_CONFIG='./config'
#determine current OS
CURRENT_OS=$(uname -s)
echo "OS detected: $CURRENT_OS"

if [ -z "$HOST" ]; then
   #If HOST parameter is not provided, use the default hostname/address:

   if [ "$CURRENT_OS" = "Darwin" ]; then
      # Max OS X - not tested!!!
      HOST=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -1);
   else
      HOST="host.docker.internal"
   fi
fi

# Display the hostname/ip address that will be applied on configuration files
COLOR='\033[1;32m'
NOCOLOR='\033[0m' # No Color
# Remove existing configuration directory (of JavaScript services)
if [ -d $DIR_CONFIG ]; then
   echo -e "Delete config ? (if yes, latest one will be downloaded with the host adress: $COLOR $HOST $NOCOLOR)? (Y/N)"
   while true; do
      read -p "" yn
      case $yn in
         [Yy]* ) ./scripts/download-config.sh; break;;
         [Nn]* ) break;;
         * ) echo "Please answer yes or no.";;
      esac
   done
fi
if [ ! -d $DIR_CONFIG ]; then
   ./scripts/download-config.sh;
fi


# Re-initialize js configuration
scripts/init.config.mono-tenant.two-dataspaces.sh $HOST

# Apply host value at KEYCLOAK_HOST variable in ENV file
sed -Ei "s#^KEYCLOAK_HOST=.*#KEYCLOAK_HOST=$HOST#g" .env

# Apply host value at HOST variable in ENV file
sed -Ei "s#^HOST=.*#HOST=$HOST#g" .env

#########################
# Start docker services #
#########################

read -p "Clean solr volumes ? (Y/N)" cl
if [ $cl = 'y' ] || [ $cl = 'Y' ]
then
   scripts/clean-solr-volumes.sh;
fi

echo "Starting Keycloak services"
#docker compose -f docker-compose-demo-keycloak.yml up -d --quiet-pull --pull always
docker compose -f docker-compose-demo-keycloak.yml up -d --quiet-pull

echo "Starting .Net services using" $DOTNET_COMPOSE_FILE
docker compose -f "$DOTNET_COMPOSE_FILE" up -d --quiet-pull

echo "Starting JS services"
docker compose -f docker-compose-demo-js.yml up -d --quiet-pull

read -p "Use api gateway (kong) and sdmx data service ? (Y/N)" cl
if [ $cl = 'y' ] || [ $cl = 'Y' ]
then
   echo "Starting kong"
   docker compose -f docker-compose-demo-kong.yml up -d --quiet-pull
   find ./config -type f -name "tenants.json" -exec sed -Ei 's#"http://'$HOST:82'#"http://'$HOST:8000'#g' {} +
fi

echo -n "Services being started."

#Wait until keycloak service is started ('Admin console listening' message appears in log')
LOG="$(docker logs keycloak 2>&1 | grep -o 'Admin console listening')"

while [ -z "$LOG" ];
do
   echo -n "."
   sleep 2

   LOG="$(docker logs keycloak 2>&1 | grep -o 'Admin console listening')"
done

echo "."
echo "Switching off HTTPS requirement in Keycloak"
./scripts/disable-ssl.sh

echo "Services started:"

docker ps