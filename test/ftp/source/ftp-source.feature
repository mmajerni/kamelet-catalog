Feature: FTP Kamelet source

  Background:
    Given variables
      | ftp.server.host      | ftp-server  |
      | ftp.server.port      | 21          |
      | ftp.server.username  | admin       |
      | ftp.server.password  | admin       |
      | ftp.server.timeout   | 250         |
      | auto.handle.commands | TYPE,PORT,PASV,PWD,SYST |
      | directoryName        | /           |
      | passiveMode          | true        |
      | file                 | message.txt |
      | message              | Camel K rocks! |
    Given HTTP server timeout is 60000 ms
    Given HTTP server "ftp-to-http-service"

  Scenario: Create Http server
    Given create Kubernetes service ftp-to-http-service with target port 8080

  Scenario: Create FTP server
    Given HTTP server "ftp-server"
    Given HTTP server listening on port 20021
    Given create Kubernetes service ftp-server with port mappings
    | 21    | 20021 |
    | 20022 | 20022 |
    And stop HTTP server
    Given load endpoint ftp-server.groovy

  Scenario: Create Pipe
    Given Camel K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    When load Pipe ftp-source-pipe.yaml
    Then Camel K integration ftp-source-pipe should be running
    And Camel K integration ftp-source-pipe should print Routes startup

  Scenario: Create FTP file
    Given sleep 5000 ms
    Then send Camel exchange to("file:~/ftp/user/admin?directoryMustExist=true&fileName=${file}") with body: ${message}

  Scenario: Verify output message sent
    Given expect HTTP request body: ${message}
    When receive POST /result
    Then send HTTP 200 OK

  Scenario: Remove resources
    Given delete Pipe ftp-source-pipe
    And delete Kubernetes service ftp-server
    And delete Kubernetes service ftp-to-http-service
    And stop server component ftp-server
