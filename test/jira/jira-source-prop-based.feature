Feature: Jira Kamelet - property based config

  Background:
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Camel-K resources
    Given Kamelet jira-source is available

  Scenario: Verify resources
    Given Camel-K integration property file jira-credentials.properties
    Given create Camel-K integration jira-to-log-prop-based.groovy
    """
    from("kamelet:jira-source/jira-credentials")
      .to('log:info')
    """
    Given Camel-K integration jira-to-log-prop-based is running
    Given variable loginfo is "Installed features"
    Then Camel-K integration jira-to-log-prop-based should print ${loginfo}

  Scenario: Verify new jira issue is created, property based config
    Given variable summary is "New bug, citrus:randomString(10)"
    Given URL: ${camel.kamelet.jira-source.jira-credentials.jiraUrl}
    And HTTP request header Authorization="Basic citrus:encodeBase64(${camel.kamelet.jira-source.jira-credentials.username}:${camel.kamelet.jira-source.jira-credentials.password})"
    And HTTP request header Content-Type="application/json"
    And HTTP request body
    """
    {
         "fields": {
               "project":
               {
                  "key": "citrus:substring(${camel.kamelet.jira-source.jira-credentials.jql}, 8)"
               },
               "summary": "${summary}",
               "description": "Yaks test of jira-source kamelet",
               "issuetype": {
                  "id": "1"
               }
           }
    }
    """
    When send POST /rest/api/2/issue/
    Then verify HTTP response expression: $.key="@variable(key)@"
    Then receive HTTP 201 CREATED
    And Camel-K integration jira-to-log-prop-based should print ${summary}
    Given URL: ${camel.kamelet.jira-source.jira-credentials.jiraUrl}
    And HTTP request header Authorization="Basic citrus:encodeBase64(${camel.kamelet.jira-source.jira-credentials.username}:${camel.kamelet.jira-source.jira-credentials.password})"
    And HTTP request header Content-Type="application/json"
    When send DELETE /rest/api/2/issue/${key}
    Then receive HTTP 204 NO_CONTENT

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration jira-to-log-prop-based
