#!/usr/bin/env bash

set -e

# Replace tokens in producer file
cat /opt/kafka/config/producer-template.properties | envsubst | sed 's/\\n/\n/g' > /opt/kafka/config/producer.properties

# Start Kafka producer
while true
do
  /opt/kafka/bin/kafka-producer-perf-test.sh \
    --topic producer-topic \
    --throughput $KAFKA_PRODUCER_THROUGHPUT \
    --num-records $KAFKA_PRODUCER_NUM_RECORDS \
    --producer.config /opt/kafka/config/producer.properties \
    --record-size 100
done