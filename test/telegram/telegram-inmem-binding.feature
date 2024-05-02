Feature: Telegram Kamelet - binding to InMemoryChannel

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"
    Given create Knative channel messages

  Scenario: Verify Kamelet source - binding to InMem
    Given Kamelet telegram-source is available
    Given load Pipe inmem-to-log.yaml
    Given load Pipe telegram-to-inmem.yaml
    Given Camel K integration telegram-to-inmem is running

    And Pipe inmem-to-log should be available
    Given variable loginfo is "Installed features"
    Then Camel K integration inmem-to-log should print ${loginfo}
    Then Camel K integration telegram-to-inmem should print ${loginfo}

    When Camel K integration telegram-to-inmem is running
    And load Kubernetes resource telegram-client.yaml
    And Camel K integration inmem-to-log should print "${message}"

    Then sleep 10000 ms

  Scenario: Remove Camel K, Kubernetes resources
    Given delete Pipe telegram-to-inmem
    Given delete Pipe inmem-to-log
    Given delete Kubernetes resource telegram-client.yaml
