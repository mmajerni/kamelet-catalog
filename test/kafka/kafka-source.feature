Feature: Kafka Kamelet source

  Background:
    Given variable user is ""
    Given variable password is ""
    Given variables
      | bootstrap.server.host     | my-cluster-kafka-bootstrap |
      | bootstrap.server.port     | 9092 |
      | securityProtocol          | PLAINTEXT |
      | deserializeHeaders        | true |
      | topic                     | my-topic |
      | source                    | Kafka Kamelet source |
      | message                   | Camel K rocks! |
    Given Kafka topic: ${topic}
    Given Kafka topic partition: 0
    Given HTTP server timeout is 15000 ms
    Given HTTP server "kafka-to-http-service"

  Scenario: Create Http server
    Given create Kubernetes service kafka-to-http-service with target port 8080

  Scenario: Create Pipe
    Given Camel K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    When load Pipe kafka-source-pipe.yaml
    Then Camel K integration kafka-source-pipe should be running
    And Camel K integration kafka-source-pipe should print Subscribing ${topic}-Thread 0 to topic ${topic}
    And sleep 10sec

  Scenario: Send message to Kafka topic and verify sink output
    Given Kafka connection
      | url         | ${bootstrap.server.host}.${YAKS_NAMESPACE}:${bootstrap.server.port} |
    When send Kafka message with body and headers: ${message}
      | event-source | ${source} |
    Then expect HTTP request body: ${message}
    Then expect HTTP request header: event-source="${source}"
    And receive POST /result
    And send HTTP 200 OK

  Scenario: Remove resources
    Given delete Pipe kafka-source-pipe
    And delete Kubernetes service kafka-to-http-service
