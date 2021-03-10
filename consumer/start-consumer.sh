#!/usr/bin/env bash

set -e

# Log in to Vault
VAULT_TOKEN=`curl -v -XPOST -d"{\"role_id\":\"${VAULT_ROLE_ID}\",\"secret_id\":\"${VAULT_ROLE_SECRET_ID}\"}" ${VAULT_ADDR}/v1/auth/approle/login | jq '.auth.client_token' -r`

# Get the client certificate
CERT_RESULT=`curl -v -H"X-Vault-Token:${VAULT_TOKEN}" -XPOST ${VAULT_ADDR}/v1/pki/kafka/issue/kafka-consumer -d"{\"common_name\":\"${HOSTNAME}\",\"ttl\":\"8760h\"}" | jq`
echo ${CERT_RESULT} | jq '.data.certificate' -r >> consumer.crt
echo ${CERT_RESULT} | jq '.data.private_key' -r >> consumer.key
echo ${CERT_RESULT} | jq '.data.issuing_ca' -r >> ca.crt

# Import into keystores
openssl pkcs12 -export -in consumer.crt -inkey consumer.key -out /tmp/consumer.p12 -name localhost -password pass:hellothere
rm -f /tmp/consumer.keystore.jks
keytool -importkeystore -destkeystore /tmp/consumer.keystore.jks -alias localhost -srcstoretype PKCS12 -srckeystore /tmp/consumer.p12  -srcstorepass hellothere -noprompt -deststorepass hellothere
rm -f /tmp/consumer.truststore.jks
keytool -keystore /tmp/consumer.truststore.jks -alias CARoot -import -file ca.crt -noprompt -storepass hellothere

# Start Kafka consumer
/opt/kafka/bin/kafka-consumer-perf-test.sh \
  --topic producer-topic \
  --messages 300 \
  --consumer.config /opt/kafka/config/consumer.properties \
  --bootstrap-server kafka1.broker.kafka.local:9093 \
  --group consumer-group \
  --timeout 300000 \
  --show-detailed-stats
