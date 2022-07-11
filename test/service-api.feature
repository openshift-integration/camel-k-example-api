Feature: Service API allows CRUD operations on S3 bucket

  Background:
    Given URL: http://api.${YAKS_NAMESPACE}.svc.cluster.local
    Given HTTP request timeout is 60000 ms

  Scenario: Create Minio S3 bucket
    Given load Kubernetes resource minio.yaml
    Then wait for Kubernetes pod labeled with app=minio

  Scenario: Create transformations integration
    Given Camel K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    Given Camel K integration property file minio.properties
    When load Camel K integration API.java with configuration
      | openapi      | openapi.yaml |
      | dependencies | camel:openapi-java |
    Then Camel K integration api should be running
    And wait for GET on path /v1

  Scenario: LIST objects
    When send GET /v1
    Then verify HTTP response body: []
    Then verify HTTP response header Content-Type="application/json"
    And receive HTTP 200 OK

  Scenario: SAVE object
    Given variable objectName is "citrus:randomString(10)"
    Given variable sampleText is "This is a sample text"
    Given HTTP request header Content-Type is "application/octet-stream"
    Given HTTP request body
      """
      ${sampleText}
      """
    When send PUT /v1/${objectName}
    Then verify HTTP response body
      """
      ${sampleText}
      """
    Then receive HTTP 204 NO_CONTENT

  Scenario: GET object
    Given variable objectName is "citrus:randomString(10)"
    Given variable sampleText is "This is another sample text"
    Given HTTP request body
      """
      ${sampleText}
      """
    Given HTTP request header Content-Type is "application/octet-stream"
    Given send PUT /v1/${objectName}
    Given receive HTTP 204 NO_CONTENT
    When send GET /v1/${objectName}
    Then verify HTTP response body
      """
      ${sampleText}
      """
    Then receive HTTP 200 OK

  Scenario: DELETE object
    Given variable objectName is "citrus:randomString(10)"
    Given variable sampleText is "This is yet another sample text"
    Given HTTP request body
      """
      ${sampleText}
      """
    Given HTTP request header Content-Type is "application/octet-stream"
    Given send PUT /v1/${objectName}
    Given receive HTTP 204 NO_CONTENT
    When send DELETE /v1/${objectName}
    Then receive HTTP 204 NO_CONTENT

  Scenario: expose OpenAPI spec
    When send GET /openapi.json
    Then expect HTTP response body loaded from openapi.yaml
    Then receive HTTP 200 OK

  Scenario: Remove Camel K integrations
    Given delete Camel K integration api
    And delete Kubernetes resource minio.yaml
