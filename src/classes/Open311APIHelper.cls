public with sharing class Open311APIHelper {

  /*
    some utility methods to be used across open311 helper
   */
  /**
    @brief Convert an ISO 8601 timestamp to an Apex \c DateTime value.
   
    Uses the JSONParser getDateTimeValue() method.
   
    See http://en.wikipedia.org/wiki/ISO_8601 for timestamp format details.
   
    Throws a System.JSONException if \p iso8601_ts is not a valid ISO 8601
    timestamp.
   
    @param iso8601_ts Valid ISO 8601 timestamp.
   
    @return a \c DateTime value for the given timestamp
   */
  public static DateTime convertTimestamp(String iso8601_ts)
  {
    // Create a valid JSON string like '{"t":"2012-07-31T11:22:33.444Z"}'
    JSONParser parser = JSON.createParser('{"t":"' + iso8601_ts + '"}');

    parser.nextToken(); // advance to the start object marker
    parser.nextValue(); // advance to the next value

    // Bug in JSONParser or DateTime object results in a malformed DateTime,
    // so convert to Long and back to DateTime.  Without the conversion,
    // methods that access timeGmt() and its components will actually get
    // local time instead of GMT.
    return DateTime.newInstance(parser.getDateTimeValue().getTime());

    // Once bug is fixed, this return is preferred.
    // return parser.getDateTimeValue();
  }

  /*
    @Purpose:-
    validate api key
   
    contains the logic for validation api key and updating response in case
    of error
   
    returns true if everything is fine / false in error
   */
  public static APIValidations.APIKeyResponse checkAPIKey(String apiKey, RestRequest req, RestResponse response, String format) {
    if (apiKey == null || apiKey == '') {
      //invalid apikey provided:-
      response.statuscode = 400;
      String responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse(' api_key not  provided') :
      CustomException.sendXMLApiErrorResponse('api_key not  provided');
      response.responseBody = Blob.valueOf(responseStr);

      return null;
    }

    APIValidations.APIKeyResponse apiKeyRes = APIValidations.validateKey(apiKey);
    System.debug('----> [Open311-Test] apiKeyRes: ' + apiKeyRes);	
    if (apiKeyRes.isValid == false) {
      //we have an invalid api key provided
      response.statuscode = 400;
      String responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse(' Invalid api_key  provided') :
      CustomException.sendXMLApiErrorResponse(' Invalid api_key  provided');
      response.responseBody = Blob.valueOf(responseStr);

      logRequest(req, 'Error', 'Invalid api_key provided');

      return null;
    }

    //System.debug('----> [Open311-Test] Open311APIHelper => apiKeyRes.usageLimitUsed >= apiKeyRes.usageLimit: ' + (apiKeyRes.usageLimitUsed >= apiKeyRes.usageLimit));
    //System.debug('----> [Open311-Test] Open311APIHelper => apiKeyRes.usageLimitResetDate == null: ' + (apiKeyRes.usageLimitResetDate == null));
    //System.debug('----> [Open311-Test] Open311APIHelper => (apiKeyRes.usageLimitResetDate.year() == Date.today().year() && apiKeyRes.usageLimitResetDate.month() == Date.today().month()): ' + ((apiKeyRes.usageLimitResetDate.year() == Date.today().year() && apiKeyRes.usageLimitResetDate.month() == Date.today().month())));

    // Verify the api usage limit access. 
    // IF: 
    // 1. Used calls is GREATER THAN OR EQUAL TO Limit amount.
    // 2. Reset date is blank not allowing for a bypass OR the last time a reset occured was this month and year.
    if (apiKeyRes.usageLimitUsed >= apiKeyRes.usageLimit && (apiKeyRes.usageLimitResetDate == null || (apiKeyRes.usageLimitResetDate.year() == Date.today().year() && apiKeyRes.usageLimitResetDate.month() == Date.today().month()))) {
      response.statuscode = 400;
      String responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse(' Usage limit exceeded for this API User.') :
      CustomException.sendXMLApiErrorResponse(' Usage limit exceeded for this API User.');
      response.responseBody = Blob.valueOf(responseStr);
      logRequest(req, 'Error', 'Usage limit exceeded for this API User.');

      return null;
    }
    return apiKeyRes;
  }

  /*
    @Purpose:-
    Create log records	       	            
   */
  public static void logRequest(RestRequest req, String status, String message) {
    /*
      create a log object
     */
    Open311_API_Log__c log = new Open311_API_Log__c();
    log.Log__c = message;
    log.status__c = status;
    log.apikey__c = req.params.get('api_key');
    log.Endpoint__c = req.requestURI;
    log.response_format__c = req.requestURI.split('\\.').size() > 1 ? req.requestURI.split('\\.') [1] : 'xml';
    log.Request_Method__c = req.httpMethod;
    log.Request_Param__c = JSON.serialize(req.params);
    insert log;

    // Build a mapping of strings for the logging params.
    Map<String, String> logParams = new Map<String, String> ();
    logParams.put('Status', status);
    logParams.put('API_Key', req.params.get('api_key'));
    logParams.put('Endpoint', req.requestURI);
    logParams.put('Response_Format', req.requestURI.split('\\.').size() > 1 ? req.requestURI.split('\\.') [1] : 'xml');
    logParams.put('Request_Method', req.httpMethod);
    logParams.putAll(req.params);

    // Get the API Name based on the Key.
    try {
      Open311ApiKeyConfig__c keyConfig = [Select Name From Open311ApiKeyConfig__c Where ApiKey__c = :req.params.get('api_key')];
      logParams.put('API_Name', keyConfig.Name);
    } catch(Exception e) {
      System.debug('----> Unable to fetch name for API Key');
    }

    try {
      String srId = '';
      /*
        // Get the Service Request ID from the message.
        List<String> messageSplit = message.split(':');
       
        if (messageSplit.size() == 2) {
        srId = messageSplit.get(1);
        srId = srId.replaceAll(' ', '');
        // Query for the case object.
        List<Case> request = [Select Id, Servicing_Agency__c, SRType__r.Name From Case Where Id = :srId]; 
        // Get fields required.
        if (request != null && request.size() == 1) {
        logParams.put('Request_Type', request.get(0).SRType__r.Name);
        logParams.put('Agency', request.get(0).Servicing_Agency__c);
        }
        }*/

      List<ServiceRequestType__c> srType = [Select Id, Name, Agency__c, Service_Name__c, External_Name__c From ServiceRequestType__c Where Name = :req.params.get('service_code')];

      if (srType != null && srType.size() == 1) {
        logParams.put('service_type', (srType.get(0).External_Name__c == null ? srType.get(0).Service_Name__c : srType.get(0).External_Name__c));
        logParams.put('agency', srType.get(0).Agency__c);
      }
    } catch(Exception e) {
      System.debug('----> Unable to get Service Request Type using given code.');
    }
    // Send the log.
    Incapsulate_Log.Loggly.singleLog(message, DateTime.now(), 'VERBOSE', logParams);
  }

  /**
   * logAPIUsage
   *
   * @description This function will increment the API keys usage in the OUC system.
   * @author Darkis
   * @param key The string representation of the API key provided by the requesting user.
   */
  public static void logAPIUsage(String key) {
    try {
      // Grab the key config for the given key.
      List<Open311ApiKeyConfig__c> keyConfig = [Select Id, Usage_Limit_Used__c, Usage_Limit_Allocation__c, Last_Request_Date__c From Open311ApiKeyConfig__c Where ApiKey__c = :key LIMIT 1];
      // If the config is available.
      if (keyConfig != null && keyConfig.size() == 1) {
        // Increment the key's usage. 
        keyConfig.get(0).Usage_Limit_Used__c = keyConfig.get(0).Usage_Limit_Used__c != null ? keyConfig.get(0).Usage_Limit_Used__c + 1 : 1;
        keyConfig.get(0).Last_Request_Date__c = Datetime.now();
        update keyConfig;
      }
    } catch(DMLException e) {
      System.debug('----> Unable to increment key usage.');
    }
  }

  public static void resetUsageLimit(String apikey) {
    try {
    List<Open311ApiKeyConfig__c> keyConfig = [Select Id, Name, ApiKey__c, Usage_Limit_Allocation__c, Usage_Limit_Used__c, Usage_Limit_Reset_Date__c FROM Open311ApiKeyConfig__c WHERE ApiKey__c = :apikey];

    if (keyConfig != null && keyConfig.size() == 1) {
      keyConfig[0].Usage_Limit_Used__c = 0;
      keyConfig[0].Usage_Limit_Reset_Date__c = Date.today();
      upsert keyConfig;
    }
    } catch (DMLException e) { 
      System.debug('----> Unable to reset usage limit for API apikey');
    }
  }

}