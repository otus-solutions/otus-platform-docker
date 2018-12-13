#!/bin/bash
DARKGRAY='\033[1;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

sudo docker-compose stop
printf "\n${DARKGRAY}#############${NC} MONGODB${DARKGRAY} #############${NC}\n"
printf "${GREEN}"
printf "Atualizando mongodb..."
cp ./mongodb/config/mongod.conf ./mongodb/persistence/mongod.conf
sleep 1
printf "\n[COMPLETO]\n\n"
printf "${NC}"

printf "***${BLUE}FIM DA ATUALIZAÇÃO${NC}***\n\n"

sudo docker-compose start
sudo docker ps
