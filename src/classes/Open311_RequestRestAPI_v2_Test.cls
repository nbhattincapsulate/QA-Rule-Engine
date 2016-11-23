/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Open311_RequestRestAPI_v2_Test {

  static String restURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/v2/';

  /* use case: test no records found */
  public static testmethod void testNoData() {

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests';
    req.requestURI = endpoint;

    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }

  public static testmethod void testWithRecordsPresentInJSON() {

    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests';
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    req.requestURI = endpoint;

    req.params.put('api_key', TestHelper.APIKey);

    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_GET__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_GET__c = TestHelper.serviceType1.name + ',';
    update config;
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }


  public static testmethod void testWithRecordsPresentApplyWrongFilters() {

    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests';
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    req.requestURI = endpoint;

    req.params.put('jurisdiction_id', 'abc');
    //req.params.put('api_key',TestHelper.APIKey);	        		        
    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }

  public static testmethod void testWithRecordsPresentApplyFilters() {

    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests';
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    req.requestURI = endpoint;

    req.params.put('jurisdiction_id', 'dc.gov');
    req.params.put('start_date', '2014-09-15T00:00:00Z');
    req.params.put('end_date', '2016-09-16T00:00:00Z');
    req.params.put('status', 'Open');
    req.params.put('api_key', TestHelper.APIKey);

    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_GET__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_GET__c = TestHelper.serviceType1.name + ',';
    update config;
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }


  public static testmethod void testWithRecordsPresentSingleSR() {

    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests';
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    req.requestURI = endpoint;

    req.params.put('service_request_id', TestHelper.caseRrd.Id);

    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }

  public static testmethod void testWithRecordsLastUpdate() {

    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests';
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_XML);
    req.requestURI = endpoint;

    req.params.put('update_date', '2014-09-15T00:00:00Z');
    req.params.put('api_key', TestHelper.APIKey);

    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_GET__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_GET__c = TestHelper.serviceType1.name + ',';
    update config;
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }


  public static testmethod void testWithRecordsPresentInXML() {

    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests';
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_GET__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_GET__c = TestHelper.serviceType1.name + ',';
    update config;
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }

  /* use case: record does not exist*/
  public static testmethod void testWithInvalidId() {

    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests/' + TestHelper.caseRrd.Id;
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_GET__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_GET__c = TestHelper.serviceType1.name + ',';
    update config;
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }


  public static testmethod void testWithValidIdXML() {

    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests/' + TestHelper.caseRrd.Id;
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_GET__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_GET__c = TestHelper.serviceType1.name + ',';
    update config;
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }

  /* use case:  */
  public static testmethod void testWithValidIdJSON() {

    TestHelper.createData();

    RestRequest req = new RestRequest();
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    String endpoint = restURL + 'requests/' + TestHelper.caseRrd.Id;
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.getRequests();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_GET__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_GET__c = TestHelper.serviceType1.name + ',';
    update config;
    Open311_RequestsRestAPI_v2.getRequests();
    Test.stopTest();
  }


  public static testmethod void testPostWithoutAPIKeyJSON() {
    System.debug('----> UNIT TEST: testPostWithoutAPIKeyJSON => BEGIN');
    TestHelper.createData();

    RestRequest req = new RestRequest();
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    String endpoint = restURL + 'requests';
    req.requestURI = endpoint;
    req.params.put('api_key', 'nogoodnogood');
    req.httpMethod = 'POST';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.createRequest();
    Test.stopTest();
  }

  public static testmethod void testPostWithAPIKeyInvalidJuridictionJSON() {
    System.debug('----> UNIT TEST: testPostWithAPIKeyInvalidJuridictionJSON => BEGIN');
    TestHelper.createData();

    RestRequest req = new RestRequest();
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    String endpoint = restURL + 'requests?aa=bb';
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    req.params.put('jurisdiction_id', 'abc');
    req.httpMethod = 'POST';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.createRequest();
    Test.stopTest();
  }
  public static testmethod void testPostWithAPIKeyInvalidJuridictionXML() {
    System.debug('----> UNIT TEST: testPostWithAPIKeyInvalidJuridictionXML => BEGIN');
    TestHelper.createData();

    RestRequest req = new RestRequest();
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_XML);
    String endpoint = restURL + 'requests?aa=bb';
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    req.params.put('jurisdiction_id', 'abc');
    req.httpMethod = 'POST';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.createRequest();
    Test.stopTest();
  }

  public static testmethod void testPostJSON() {
    System.debug('----> UNIT TEST: testPostJSON => BEGIN');
    TestHelper.createData();

    RestRequest req = new RestRequest();
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    String endpoint = restURL + 'requests?nothing=this'; ///+'&jurisdiction_id=abc';
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);

    System.debug('----> [Open311-Test] API Key for test request: ' + TestHelper.APIKey);
    //req.params.put('jurisdiction_id','dc.gov');	    

    req.params.put('description', 'testing');
    req.params.put('address_string', 'testing DC');
    req.params.put('media_url', 'testing');
    req.params.put('first_name', 'Jimmy');
    req.params.put('last_name', 'demo');
    req.params.put('service_code', TestHelper.serviceType1.name);
    req.params.put('attributes[Test1]', 'A123');
    req.params.put('attributes[Test3]', 'this is a test ans2');
    req.params.put('address_id', '224728');
    req.params.put('lat', '38.92357688');
    req.params.put('long', '-77.09806023');

    Open311_RequestsRestAPI_v2.ActivityWrapper tsk = new Open311_RequestsRestAPI_v2.ActivityWrapper();
    tsk.Task_code = '1111';
    tsk.Task_Short_Name = 'testing name';

    List<Open311_RequestsRestAPI_v2.ActivityWrapper> tasks = new List<Open311_RequestsRestAPI_v2.ActivityWrapper> ();
    tasks.add(tsk);

    req.params.put('tasks', JSON.serialize(tasks));

    req.httpMethod = 'POST';
    RestContext.request = req;
    Test.startTest();
    // Test false path with blocked service code.
    Open311_RequestsRestAPI_v2.createRequest();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_POST__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_POST__c = TestHelper.serviceType1.name + ',';
    update config;
    Open311_RequestsRestAPI_v2.createRequest();
    Test.stopTest();
    System.debug('----> UNIT TEST: testPostJSON => END');
  }

  public static testmethod void testPostWithXML() {
    System.debug('----> UNIT TEST: testPostWithXML => BEGIN');
    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests?ae=ea';
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    //req.params.put('jurisdiction_id','dc.gov');	 

    req.params.put('description', 'testing');
    req.params.put('address_string', '441 4th St');
    req.params.put('media_url', 'testing');
    req.params.put('first_name', 'Jimmy');
    req.params.put('last_name', 'demo');
    req.params.put('service_code', TestHelper.serviceType1.name);
    req.params.put('attributes[Test1]', 'this is a test ans');
    req.params.put('attributes[Test3]', 'this is a test ans2');

    Open311_RequestsRestAPI_v2.ActivityWrapper tsk = new Open311_RequestsRestAPI_v2.ActivityWrapper();
    tsk.Task_code = '1111';
    tsk.Task_Short_Name = 'testing name';

    List<Open311_RequestsRestAPI_v2.ActivityWrapper> tasks = new List<Open311_RequestsRestAPI_v2.ActivityWrapper> ();
    tasks.add(tsk);

    req.params.put('tasks', JSON.serialize(tasks));

    req.httpMethod = 'POST';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.createRequest();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_POST__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_POST__c = TestHelper.serviceType1.name + ',';
    update config;
    Open311_RequestsRestAPI_v2.createRequest();
    Test.stopTest();
  }

  public static testmethod void testUpdate() {
    System.debug('----> UNIT TEST: testUpdate => BEGIN');  
    TestHelper.createData();
    Case c = [Select Id, Origin, Status, ContactId, SRType__c, Service_Request_Number__c, CaseNumber From Case Where Id = :TestHelper.caseRrd.Id];
    System.debug('----> Case: ' + c);

    RestRequest req = new RestRequest();
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    String endpoint = restURL + 'requests?a=b';
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    //req.params.put('jurisdiction_id','dc.gov');	    
    req.params.put('service_request_id', c.Service_Request_Number__c);
    System.debug('----> UNIT TEST PUT: SR Id => ' + TestHelper.caseRrd);
    req.params.put('description', 'testing');
    //req.params.put('address_string','testing DC');
    req.params.put('media_url', 'testingseventeen');


    Open311_RequestsRestAPI_v2.ActivityWrapper tsk = new Open311_RequestsRestAPI_v2.ActivityWrapper();
    tsk.Task_code = '1111';
    tsk.Task_Short_Name = 'testing name';

    List<Open311_RequestsRestAPI_v2.ActivityWrapper> tasks = new List<Open311_RequestsRestAPI_v2.ActivityWrapper> ();
    tasks.add(tsk);

    req.params.put('tasks', JSON.serialize(tasks));

    req.httpMethod = 'PUT';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.doUpdate();
    // Test true path with service code.
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_PUT__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_PUT__c = 'DMV19,';
    update config;
    Open311_RequestsRestAPI_v2.createRequest();
    Test.stopTest();
  }

  public static testmethod void testUpdateWithXML() {
      System.debug('----> UNIT TEST: testUpdateWithXML => BEGIN');  
    TestHelper.createData();

    RestRequest req = new RestRequest();

    String endpoint = restURL + 'requests?dd=aa';
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    //req.params.put('jurisdiction_id','dc.gov');	    
    req.params.put('service_request_id', TestHelper.caseRrd.CaseNumber);
    req.params.put('description', 'testing');
    req.params.put('address_string', 'testing DC');
    req.params.put('media_url', 'testing');


    Open311_RequestsRestAPI_v2.ActivityWrapper tsk = new Open311_RequestsRestAPI_v2.ActivityWrapper();
    tsk.Task_code = '1111';
    tsk.Task_Short_Name = 'testing name';

    List<Open311_RequestsRestAPI_v2.ActivityWrapper> tasks = new List<Open311_RequestsRestAPI_v2.ActivityWrapper> ();
    tasks.add(tsk);

    req.params.put('tasks', JSON.serialize(tasks));

    Open311ApiKeyConfig__c config = [Select Id, isCommentsRequired__c, Available_SR_Types_For_PUT__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_PUT__c = 'DMV19,';
    config.isCommentsRequired__c = true;
    update config;

    req.httpMethod = 'PUT';
    RestContext.request = req;
    Test.startTest();
    Open311_RequestsRestAPI_v2.doUpdate();
    Test.stopTest();
  }

  public static testmethod void testUpdateWithInvalidId() {
      System.debug('----> UNIT TEST: testUpdateWithInvalidId => BEGIN');  
    TestHelper.createData();

    RestRequest req = new RestRequest();
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    String endpoint = restURL + 'requests?a=a';
    req.requestURI = endpoint;
    req.params.put('api_key', TestHelper.APIKey);
    req.params.put('full_status', 'open');
    //req.params.put('jurisdiction_id','dc.gov');	    
    req.params.put('service_request_id', 'InvalidSRID');
    req.params.put('description', 'testing');
    //req.params.put('address_string','testing DC');
    req.params.put('media_url', 'testing');


    Open311_RequestsRestAPI_v2.ActivityWrapper tsk = new Open311_RequestsRestAPI_v2.ActivityWrapper();
    tsk.Task_code = '1111';
    tsk.Task_Short_Name = 'testing name';

    List<Open311_RequestsRestAPI_v2.ActivityWrapper> tasks = new List<Open311_RequestsRestAPI_v2.ActivityWrapper> ();
    tasks.add(tsk);

    req.params.put('tasks', JSON.serialize(tasks));

    req.httpMethod = 'PUT';
    RestContext.request = req;
    Test.startTest();
    Open311ApiKeyConfig__c config = [Select Id, Available_SR_Types_For_PUT__c From Open311ApiKeyConfig__c Where ApiKey__c = :TestHelper.APIKey];
    config.Available_SR_Types_For_PUT__c = 'DMV19,';
    update config;
    Open311_RequestsRestAPI_v2.doUpdate();
    Test.stopTest();
  }

}