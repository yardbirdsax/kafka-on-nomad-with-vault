FROM yardbirdsax/kafka:2.13-2.7.0

RUN apk add openssl

COPY consumer.properties /opt/kafka/config/consumer.properties
COPY start-consumer.sh /opt/kafka/start-consumer.sh

RUN chmod +x /opt/kafka/start-consumer.sh

ENTRYPOINT [ "/bin/bash","-c","/opt/kafka/start-consumer.sh" ]