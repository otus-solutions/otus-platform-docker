#!/bin/bash
DARKGRAY='\033[1;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf "\n * * * MONGODB * * * \n"
printf "PASSWORD Mongo Admin(default = ${YELLOW}XRYs9yjU${NC}): "
read passAdmin
if [ -z $passAdmin ]; then
    passAdmin='XRYs9yjU'
fi
printf "PASSWORD Mongo Otus(default = ${YELLOW}a9J1sVtL${NC}): "
read passOtus
if [ -z $passOtus ]; then
    passOtus='a9J1sVtL'
fi
printf "PASSWORD Mongo Domain(default = ${YELLOW}fLACLaFL${NC}): "
read passDomain
if [ -z $passDomain ]; then
    passDomain='fLACLaFL'
fi


printf "\n\n * * * WILDFLY * * * \n"
printf "User Wildfly Admin(default = ${YELLOW}admin${NC}): "
read user_wildfly
if [ -z $user_wildfly ]; then
    user_wildfly='admin'
fi
printf "Password Wildfly Admin(default = ${YELLOW}rBQqsMXU${NC}): "
read pass_wildfly
if [ -z $pass_wildfly ]; then
    pass_wildfly='rBQqsMXU'
fi


printf "Disable Debug Mode(y/n): "
read debug
case $debug in
    y)
        printf "${RED}DEBUG MODE DISABLED${NC}\n"
        ;;
    *)
        printf "DEBUG MODE ENABLED\n"
        ;;
esac

printf "\n\n * * * NGINX * * * \n"
printf "OTUS HOST(default = ${YELLOW}otus.localhost${NC}): "
read otus
if [ -z $otus ]; then
    otus='otus.localhost'
fi

printf "DOMAIN HOST(default = ${YELLOW}domain.localhost${NC}): "
read domain
if [ -z $domain ]; then
    domain='domain.localhost'
fi

printf "STUDIO HOST(default = ${YELLOW}studio.localhost${NC}): "
read studio
if [ -z $studio ]; then
    studio='studio.localhost'
fi

printf "ASSETS HOST(default = ${YELLOW}assets.localhost${NC}): "
read assets
if [ -z $assets ]; then
    assets='assets.localhost'
fi

printf "OTUS API HOST(default = ${YELLOW}api-otus.localhost${NC}): "
read otus_api
if [ -z $otus_api ]; then
    otus_api='api-otus.localhost'
fi

printf "DOMAIN API HOST(default = ${YELLOW}api-domain.localhost${NC}): "
read domain_api
if [ -z $domain_api ]; then
    domain_api='api-domain.localhost'
fi

printf "\nAs informações acima estão corretas? Deseja prosseguir(ENTER): "
read ANSWER



printf "\n${DARKGRAY}#############${NC} MONGODB${DARKGRAY} #############${NC}\n"
printf "${GREEN}"
printf "Atualizando passwords mongodb..."
cp ./mongodb/config/example-initdb.js ./mongodb/persistence/otus-db-build.js
cp ./mongodb/config/mongod.conf ./mongodb/persistence/mongod.conf
sed -i "s/PASS_ADMIN/$passAdmin/g" ./mongodb/persistence/otus-db-build.js
sed -i "s/PASS_OTUS/$passOtus/g" ./mongodb/persistence/otus-db-build.js
sed -i "s/PASS_DOMAIN/$passDomain/g" ./mongodb/persistence/otus-db-build.js
sleep 1
printf "\n[COMPLETO]\n\n"
printf "${NC}"

printf "${DARKGRAY}#############${NC} WILDFLY${DARKGRAY} #############${NC}\n"
printf "${GREEN}"
printf "Atualizando usuário Wildfly...\n"
sed -i -E "s/WILDFLY_USER=.+/WILDFLY_USER=$user_wildfly/g" .env
sed -i -E "s/WILDFLY_PASS=.+/WILDFLY_PASS=$pass_wildfly/g" .env

sudo rm -rf ./wildfly/persistence/wildfly
mkdir -p ./wildfly/persistence/wildfly/conf
cp ./wildfly/config/standalone.xml ./wildfly/persistence/wildfly/conf/standalone.xml
mkdir -p ./wildfly/persistence/wildfly/bin
cp ./wildfly/config/standalone.conf ./wildfly/persistence/wildfly/bin/standalone.conf
case $debug in
    y)
        printf "${RED}DEBUG MODE DISABLED${NC}\n"
        ;;
    *)
        sed -i "s/#debug/JAVA_OPTS/g" ./wildfly/persistence/wildfly/bin/standalone.conf
        ;;
esac

sleep 1
printf "\n[COMPLETO]\n\n"
printf "${NC}"

printf "${DARKGRAY}#############${NC} NGINX${DARKGRAY} #############${NC}\n"
printf "${GREEN}"
printf "Gerando arquivos de host...\n"
sudo rm -rf ./nginx/persistence/*
mkdir -p ./nginx/persistence/sites-enabled/
cp ./nginx/config/sites-available/otus.template ./nginx/persistence/sites-enabled/otus.conf
cp ./nginx/config/sites-available/api-otus.template ./nginx/persistence/sites-enabled/api-otus.conf
cp ./nginx/config/sites-available/domain.template ./nginx/persistence/sites-enabled/domain.conf
cp ./nginx/config/sites-available/api-domain.template ./nginx/persistence/sites-enabled/api-domain.conf
cp ./nginx/config/sites-available/studio.template ./nginx/persistence/sites-enabled/studio.conf
cp ./nginx/config/sites-available/assets.template ./nginx/persistence/sites-enabled/assets.conf
cp -R ./nginx/config/ssl/ ./nginx/persistence/
cp ./nginx/config/nginx.conf ./nginx/persistence/nginx.conf
sleep 1
printf "Atualizando server names...\n"
sed -i "s/localhost/$otus/g" ./nginx/persistence/sites-enabled/otus.conf
sed -i "s/localhost/$domain/g" ./nginx/persistence/sites-enabled/domain.conf
sed -i "s/localhost/$studio/g" ./nginx/persistence/sites-enabled/studio.conf
sed -i "s/localhost/$assets/g" ./nginx/persistence/sites-enabled/assets.conf
sed -i "s/localhost/$otus_api/g" ./nginx/persistence/sites-enabled/api-otus.conf
sed -i "s/localhost/$domain_api/g" ./nginx/persistence/sites-enabled/api-domain.conf
sleep 1
printf "\n[COMPLETO]\n\n"
printf "${NC}"

printf "***${BLUE}FIM DA CONFIGURAÇÃO${NC}***\n\n"

sudo docker-compose up -d
sudo chmod -R 775 ./wildfly/persistence
sudo chmod -R 775 ./nginx/persistence/html
sudo chmod -R 775 ./nginx/persistence/sites-enabled
sudo docker ps
