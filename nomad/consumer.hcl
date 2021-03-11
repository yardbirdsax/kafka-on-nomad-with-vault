job "kafka-consumer" {
  datacenters = ["dc1"]

  group "demo" {
    task "task" {
      vault {
        policies  = ["kafka-consumer"]
      }

      env {
        KAFKA_CONSUMER_NUM_RECORDS = 10
        KAFKA_CONSUMER_TIMEOUT = 30000
      }

      driver = "docker"
      config {
        image = "kafka-consumer:1.0"
        network_mode = "kafka"
        # entrypoint = ["/bin/sh","-c","while true; do echo sleeping...; sleep 30; done;"]
      }

      template {
        data        = <<EOF
SSL_KEYSTORE_CERTIFICATE_CHAIN={{ with secret "pki/kafka/issue/kafka-consumer" "common_name=consumer1.consumer.kafka.local" "formet=pem" "private_key_format=pkcs8" }}{{- .Data.certificate | regexReplaceAll "\n" " \\\\n" -}}{{ end }}
SSL_KEYSTORE_KEY={{ with secret "pki/kafka/issue/kafka-consumer" "common_name=consumer1.consumer.kafka.local" "formet=pem" "private_key_format=pkcs8" }}{{- .Data.private_key | regexReplaceAll "\n" " \\\\n" -}}{{ end }}
SSL_TRUSTSTORE_CERTIFICATE_CHAIN={{ with secret "pki/kafka/issue/kafka-consumer" "common_name=consumer1.consumer.kafka.local" "formet=pem" "private_key_format=pkcs8" }}{{- .Data.issuing_ca | regexReplaceAll "\n" " \\\\n" -}}{{ end }}
EOF
        destination = "${NOMAD_SECRETS_DIR}/secrets.env"
        env         = true
      }

      resources {
        memory = 1024
      }
    }
  }
}