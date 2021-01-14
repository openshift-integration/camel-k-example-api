Feature: the API allows CRUD operations on a S3 bucket


  Background:
    Given Camel-K integration api is running
    Given URL: http://api.${YAKS_NAMESPACE}.svc.cluster.local
    Given HTTP request timeout is 60000 ms
    And wait for GET on path /v1


  Scenario: LIST objects
    When send GET /v1
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
    Then receive HTTP 200 OK


  Scenario: GET object
    Given variable objectName is "citrus:randomString(10)"
    Given variable sampleText is "This is another sample text"
    Given HTTP request body
      """
      ${sampleText}
      """
    Given HTTP request header Content-Type is "application/octet-stream"
    Given send PUT /v1/${objectName}
    Given receive HTTP 200 OK
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
    Given receive HTTP 200 OK
    When send DELETE /v1/${objectName}
    Then receive HTTP 204 OK


  Scenario: expose OpenAPI
    When send GET /openapi.json
    Then receive HTTP 200 OK
