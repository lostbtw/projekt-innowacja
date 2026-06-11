public with sharing class MissingAnimalsAuthService {
  private static final String TOKEN_PATH = '/services/oauth2/token';
  private static final String GRANT_TYPE = 'client_credentials';
  private static final String DEFAULT_CONFIG = 'Default';

  public static AuthTocken cachedTocken;

  public class AuthException extends Exception {
  }

  public class AuthTocken {
    public String access_token { get; set; }
    public String instance_url { get; set; }
    public Long issued_at { get; set; }
    public String token_type { get; set; }

    public AuthToken(Map<String, Object> raw) {
      this.accessToken = (String) raw.get('access_token');
      this.instanceUrl = (String) raw.get('instance_url');
      this.tokenType = (String) raw.get('token_type');

      Object issued = raw.get('issued_at');
      if (issued != null) {
        this.issuedAt = Long.valueOf(String.valueOf(issued));
      }
    }

    public static AuthToken getAccessToken() {
      return getAccessToken(DEFAULT_CONFIG);
    }

    public static AuthToken getAccessToken(String configName) {
      if (cachedToken != null) {
        return cachedToken;
      }

      Missing_Animals_Auth__mdt config = Missing_Animals_Auth__mdt.getInstance(
        configName
      );

      if (config == null) {
        throw new AuthException(
          'Missing authentication configuration: ' +
            configName +
            '. Create a Custom Metadata record Missing_Animals_Auth__mdt.' +
            configName
        );
      }

      validateConfig(config);

      cachedToken = requestToken(config);
      return cachedToken;
    }

    public static void clearCachedToken() {
      cachedToken = null;
    }

    private static void validateConfig(Missing_Animals_Auth__mdt config) {
      if (String.isBlank(config.Login_URL__c)) {
        throw new AuthException(
          'Login_URL__c is blank in config: ' + config.DeveloperName
        );
      }
      if (String.isBlank(config.Client_Id__c)) {
        throw new AuthException(
          'Client_Id__c is blank in config: ' + config.DeveloperName
        );
      }
      if (String.isBlank(config.Client_Secret__c)) {
        throw new AuthException(
          'Client_Secret__c is blank in config: ' + config.DeveloperName
        );
      }
    }

    private static AuthToken requestToken(Missing_Animals_Auth__mdt config) {
      HttpRequest req = new HttpRequest();
      req.setEndpoint(config.Login_URL__c + TOKEN_PATH);
      req.setMethod('POST');
      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setTimeout(9999);

      String body =
        'grant_type=' +
        GRANT_TYPE +
        '&client_id=' +
        EncodingUtil.urlEncode(config.Client_Id__c, 'UTF-8') +
        '&client_secret=' +
        EncodingUtil.urlEncode(config.Client_Secret__c, 'UTF-8');

      req.setBody(body);

      Http http = new Http();
      HttpResponse res;

      try {
        res = http.send(req);
      } catch (CalloutException e) {
        throw new AuthException(
          'Callout to token endpoint failed: ' + e.getMessage()
        );
      }

      if (res.getStatusCode() != 200) {
        throw new AuthException(
          'OAuth token request failed.' +
            ' Status: ' +
            res.getStatusCode() +
            ' Body: ' +
            res.getBody()
        );
      }

      Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );

      if (!responseMap.containsKey('access_token')) {
        throw new AuthException(
          'Response does not contain access_token. Body: ' + res.getBody()
        );
      }

      return new AuthToken(responseMap);
    }
  }
}
