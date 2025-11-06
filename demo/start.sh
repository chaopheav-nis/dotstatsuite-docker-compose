#!/bin/bash

DOTNET_COMPOSE_FILE="docker-compose-demo-dotnet.yml"

##################
# Initialization #
##################
HOST=$1
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

echo "Starting Keycloak services"
docker compose -f docker-compose-demo-keycloak.yml up -d --quiet-pull

echo "Starting .Net services using" $DOTNET_COMPOSE_FILE
docker compose -f "$DOTNET_COMPOSE_FILE" up -d --quiet-pull

echo "Starting JS services"
docker compose -f docker-compose-demo-js.yml up -d --quiet-pull

echo "Adding read access for anonymous (all) users if not yet added"
source ./.env
docker exec -i mssql //opt/mssql-tools18/bin/sqlcmd -C -S $SQL_SERVER_HOST -U $DB_SA_USER -P $DB_SA_PASSWORD -Q "INSERT INTO $COMMON_DB.[dbo].[AUTHORIZATIONRULES] ([USERMASK],[ISGROUP],[DATASPACE],[ARTEFACTTYPE],[ARTEFACTAGENCYID],[ARTEFACTID],[ARTEFACTVERSION],[PERMISSION],[EDITEDBY],[EDITDATE]) SELECT '*',0,'*',0,'*','*','*',3,'system',getdate() WHERE NOT EXISTS (SELECT 1 FROM COMMONDB.[dbo].[AUTHORIZATIONRULES] WHERE [USERMASK]='*' AND [ISGROUP]=0 AND [DATASPACE]='*' AND [ARTEFACTTYPE]=0 AND [ARTEFACTAGENCYID]='*' AND [ARTEFACTID]='*' AND [ARTEFACTVERSION]='*');"

echo "Services started:"

docker ps