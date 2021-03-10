#!/usr/bin/env bash

set -e

# Log in to Vault
VAULT_TOKEN=`curl -XPOST -d"{\"role_id\":\"${VAULT_ROLE_ID}\",\"secret_id\":\"${VAULT_ROLE_SECRET_ID}\"}" ${VAULT_ADDR}/v1/auth/approle/login | jq '.auth.client_token' -r`

# Get the client certificate
CERT_RESULT=`curl -H"X-Vault-Token:${VAULT_TOKEN}" -XPOST ${VAULT_ADDR}/v1/pki/kafka/issue/kafka-broker -d"{\"common_name\":\"${HOSTNAME}\",\"ttl\":\"8760h\"}" | jq`
echo ${CERT_RESULT} | jq '.data.certificate' -r >> server.crt
echo ${CERT_RESULT} | jq '.data.private_key' -r >> server.key
echo ${CERT_RESULT} | jq '.data.issuing_ca' -r >> ca.crt

# Import into keystores
openssl pkcs12 -export -in server.crt -inkey server.key -out /tmp/server.p12 -name localhost -password pass:hellothere
rm -f /tmp/server.keystore.jks
keytool -importkeystore -destkeystore /tmp/server.keystore.jks -alias localhost -srcstoretype PKCS12 -srckeystore /tmp/server.p12  -srcstorepass hellothere -noprompt -deststorepass hellothere
rm -f /tmp/server.truststore.jks
keytool -keystore /tmp/server.truststore.jks -alias CARoot -import -file ca.crt -noprompt -storepass hellothere

# Replace the host name
sed -i "s/<host>/$(hostname)/g" /opt/kafka/config/server.properties

# Start Kafka
/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
