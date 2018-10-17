#!/bin/bash -e

. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

rm -rf /bitnami/wildfly/
mkdir -p /bitnami/wildfly/conf
mkdir -p /bitnami/wildfly/bin

print_welcome_page

if [[ "$1" == "nami" && "$2" == "start" ]] || [[ "$1" == "/init.sh" ]]; then
  nami_initialize wildfly
  info "Starting wildfly... "

fi
cp ./config/standalone.xml /bitnami/wildfly/conf/standalone.xml
cp ./config/standalone.conf /bitnami/wildfly/bin/standalone.conf

exec tini -- "$@"


