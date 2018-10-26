#!/bin/bash
DARKGRAY='\033[1;30m'
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


printf "Enable Debug Mode(y/n): "
read debug
case $debug in
    y)
        printf "DEBUG MODE ENABLED\n"
        ;;
    *)
        printf "DEBUG MODE DISABLED\n"
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

printf "\n${DARKGRAY}#############${NC} MONGODB${DARKGRAY} #############${NC}\n"
printf "${GREEN}"
printf "Atualizando passwords mongodb..."
cp ./mongodb/example.js ./mongodb/otus-db-build.js
sed -i "s/PASS_ADMIN/$passAdmin/g" ./mongodb/otus-db-build.js
sed -i "s/PASS_OTUS/$passOtus/g" ./mongodb/otus-db-build.js
sed -i "s/PASS_DOMAIN/$passDomain/g" ./mongodb/otus-db-build.js
sleep 1
printf "\n[COMPLETO]\n\n"
printf "${NC}"

printf "${DARKGRAY}#############${NC} WILDFLY${DARKGRAY} #############${NC}\n"
printf "${GREEN}"
printf "Atualizando usuário Wildfly...\n"
sed -i -E "s/WILDFLY_USER=.+/WILDFLY_USER=$user_wildfly/g" .env
sed -i -E "s/WILDFLY_PASS=.+/WILDFLY_PASS=$pass_wildfly/g" .env

sudo rm -rf ./wildfly/persistence/wildfly


sleep 1
printf "\n[COMPLETO]\n\n"
printf "${NC}"

printf "${DARKGRAY}#############${NC} NGINX${DARKGRAY} #############${NC}\n"
printf "${GREEN}"
printf "Gerando arquivos de host...\n"
cp ./nginx/sites-available/otus.template ./nginx/sites-enabled/otus.conf
cp ./nginx/sites-available/api-otus.template ./nginx/sites-enabled/api-otus.conf
cp ./nginx/sites-available/domain.template ./nginx/sites-enabled/domain.conf
cp ./nginx/sites-available/api-domain.template ./nginx/sites-enabled/api-domain.conf
cp ./nginx/sites-available/studio.template ./nginx/sites-enabled/studio.conf
cp ./nginx/sites-available/assets.template ./nginx/sites-enabled/assets.conf
# cp ./nginx/sites-available/localhost.template ./nginx/conf.d/default.conf
sleep 1
printf "Atualizando server names...\n"
sed -i "s/localhost/$otus/g" ./nginx/sites-enabled/otus.conf
sed -i "s/localhost/$domain/g" ./nginx/sites-enabled/domain.conf
sed -i "s/localhost/$studio/g" ./nginx/sites-enabled/studio.conf
sed -i "s/localhost/$assets/g" ./nginx/sites-enabled/assets.conf
sed -i "s/localhost/$otus_api/g" ./nginx/sites-enabled/api-otus.conf
sed -i "s/localhost/$domain_api/g" ./nginx/sites-enabled/api-domain.conf
sleep 1
printf "\n[COMPLETO]\n\n"
printf "${NC}"

printf "***${BLUE}FIM DA CONFIGURAÇÃO${NC}***\n\n"


sudo chmod -R 777 ./wildfly/persistence
mkdir -p ./wildfly/persistence/wildfly/conf
case $debug in
    y)
        mkdir -p ./wildfly/persistence/wildfly/bin
        cp ./wildfly/config/standalone.conf ./wildfly/persistence/wildfly/bin/standalone.conf
        ;;
esac

cp ./wildfly/config/standalone.xml ./wildfly/persistence/wildfly/conf/standalone.xml
# docker restart otus_backend
sudo docker-compose up -d
sudo docker ps

