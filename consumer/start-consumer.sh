#!/usr/bin/env bash

set -e

# Replace tokens in producer file
cat /opt/kafka/config/consumer-template.properties | envsubst | sed 's/\\n/\n/g' > /opt/kafka/config/consumer.properties

# Start Kafka consumer
while true
do 
  /opt/kafka/bin/kafka-consumer-perf-test.sh \
    --topic producer-topic \
    --messages ${KAFKA_CONSUMER_NUM_RECORDS} \
    --consumer.config /opt/kafka/config/consumer.properties \
    --bootstrap-server kafka1.broker.kafka.local:9093 \
    --timeout ${KAFKA_CONSUMER_TIMEOUT}
done
