FROM yardbirdsax/kafka:2.13-2.7.0

RUN apk add openssl

COPY server.properties /opt/kafka/config/server.properties
COPY adminconfig.properties /opt/kafka/config/
COPY start-kafka.sh /opt/kafka/start-kafka.sh

RUN chmod +x /opt/kafka/start-kafka.sh

ENTRYPOINT [ "/bin/bash","-c","/opt/kafka/start-kafka.sh" ]
