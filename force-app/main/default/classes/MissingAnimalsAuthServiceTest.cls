@IsTest
private class MissingAnimalsAuthServiceTest {
  private class SuccessMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        JSON.serialize(
          new Map<String, Object>{
            'access_token' => 'mock_access_token_abc123',
            'instance_url' => 'https://my-sandbox.salesforce.com',
            'token_type' => 'Bearer',
            'issued_at' => String.valueOf(System.currentTimeMillis())
          }
        )
      );
      return res;
    }
  }

  private class ErrorMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(400);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"error":"invalid_client","error_description":"invalid client credentials"}'
      );
      return res;
    }
  }

  @IsTest
  static void testSuccessfulTokenRetrieval() {
    Test.setMock(HttpCalloutMock.class, new SuccessMock());

    Test.startTest();
    MissingAnimalsAuthService.AuthToken token = MissingAnimalsAuthService.getAccessToken();
    Test.stopTest();

    System.assertNotEquals(null, token, 'Token should not be null');
    System.assertEquals('mock_access_token_abc123', token.accessToken);
    System.assertEquals('https://my-sandbox.salesforce.com', token.instanceUrl);
    System.assertEquals('Bearer', token.tokenType);
    System.assertNotEquals(null, token.issuedAt);
  }

  @IsTest
  static void testTokenIsCachedWithinTransaction() {
    Test.setMock(HttpCalloutMock.class, new SuccessMock());

    Test.startTest();
    MissingAnimalsAuthService.AuthToken first = MissingAnimalsAuthService.getAccessToken();
    MissingAnimalsAuthService.AuthToken second = MissingAnimalsAuthService.getAccessToken();
    Test.stopTest();

    System.assert(first === second, 'Second call should return cached token');
  }

  @IsTest
  static void testClearCachedTokenForcesNewRequest() {
    Test.setMock(HttpCalloutMock.class, new SuccessMock());

    Test.startTest();
    MissingAnimalsAuthService.AuthToken first = MissingAnimalsAuthService.getAccessToken();
    MissingAnimalsAuthService.clearCachedToken();
    MissingAnimalsAuthService.AuthToken second = MissingAnimalsAuthService.getAccessToken();
    Test.stopTest();

    System.assert(
      first !== second,
      'After clearing cache, a new token should be fetched'
    );
    System.assertEquals(first.accessToken, second.accessToken);
  }

  @IsTest
  static void testFailedTokenRequestThrowsException() {
    Test.setMock(HttpCalloutMock.class, new ErrorMock());

    Test.startTest();
    try {
      MissingAnimalsAuthService.getAccessToken();
      System.assert(false, 'Should have thrown AuthException');
    } catch (MissingAnimalsAuthService.AuthException e) {
      System.assert(
        e.getMessage().contains('400'),
        'Exception should contain status code'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void testMissingConfigThrowsException() {
    Test.startTest();
    try {
      MissingAnimalsAuthService.getAccessToken('NonExistentConfig');
      System.assert(false, 'Should have thrown AuthException');
    } catch (MissingAnimalsAuthService.AuthException e) {
      System.assert(
        e.getMessage().contains('Missing authentication configuration'),
        'Exception should mention missing config'
      );
    }
    Test.stopTest();
  }
}
