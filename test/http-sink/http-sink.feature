Feature: Http Kamelet sink

  Background:
    Given HTTP server timeout is 15000 ms
    Given HTTP server "sink-http-service"
    Given variable message is "Camel K rocks!"

  Scenario: Create Http server
    Given create Kubernetes service sink-http-service

  Scenario: Create Pipe
    Given Camel K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    When load Pipe http-sink-pipe.yaml
    Then Camel K integration http-sink-pipe should be running

  Scenario: Verify request message sent
    Given expect HTTP request body: ${message}
    And expect HTTP request header: Content-Type="text/plain"
    When receive POST /result
    Then send HTTP 201 CREATED

  Scenario: Remove resources
    Given delete Pipe http-sink-pipe
    And delete Kubernetes service sink-http-service
