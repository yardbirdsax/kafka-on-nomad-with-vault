job "kafka-producer" {
  datacenters = ["dc1"]

  group "demo" {
    task "task" {
      vault {
        policies  = ["kafka-producer"]
      }

      env {
        KAFKA_PRODUCER_THROUGHPUT = 100
        KAFKA_PRODUCER_NUM_RECORDS = 100000
      }

      driver = "docker"
      config {
        image = "kafka-producer:1.0"
        network_mode = "kafka"
      }

      template {
        data        = <<EOF
SSL_KEYSTORE_CERTIFICATE_CHAIN={{ with secret "pki/kafka/issue/kafka-producer" "common_name=producer1.producer.kafka.local" "formet=pem" "private_key_format=pkcs8" }}{{- .Data.certificate | regexReplaceAll "\n" " \\\\n" -}}{{ end }}
SSL_KEYSTORE_KEY={{ with secret "pki/kafka/issue/kafka-producer" "common_name=producer1.producer.kafka.local" "formet=pem" "private_key_format=pkcs8" }}{{- .Data.private_key | regexReplaceAll "\n" " \\\\n" -}}{{ end }}
SSL_TRUSTSTORE_CERTIFICATE_CHAIN={{ with secret "pki/kafka/issue/kafka-producer" "common_name=producer1.producer.kafka.local" "formet=pem" "private_key_format=pkcs8" }}{{- .Data.issuing_ca | regexReplaceAll "\n" " \\\\n" -}}{{ end }}
EOF
        destination = "${NOMAD_SECRETS_DIR}/secrets.env"
        env         = true
      }
    }
  }
}