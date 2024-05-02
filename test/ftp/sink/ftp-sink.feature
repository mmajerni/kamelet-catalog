Feature: FTP Kamelet sink

  Background:
    Given variables
      | ftp.server.host     | ftp-server  |
      | ftp.server.port     | 21          |
      | ftp.server.username | admin       |
      | ftp.server.password | admin       |
      | ftp.server.timeout   | 15000      |
      | auto.handle.commands | TYPE,PORT,PASV |
      | directoryName       | /           |
      | passiveMode         | true        |
      | file                | message.txt |
      | message             | Camel K rocks! |

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
    When load Pipe ftp-sink-pipe.yaml
    Then Camel K integration ftp-sink-pipe should be running

  Scenario: Verify FTP file created
    When endpoint ftp-server receives body
    """
    {
      "signal": "STOR",
      "arguments": "${file}"
    }
    """
    Then endpoint ftp-server sends body
    """
    {
      "success": true
    }
    """

  Scenario: Verify file content
    Then receive Camel exchange from("file:~/ftp/user/admin?directoryMustExist=true&fileName=${file}") with body: ${message}

  Scenario: Remove resources
    Given delete Pipe ftp-sink-pipe
    And delete Kubernetes service ftp-server
    And stop server component ftp-server
