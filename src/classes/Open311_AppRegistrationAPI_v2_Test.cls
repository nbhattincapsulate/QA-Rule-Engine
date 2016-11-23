@isTest
public class Open311_AppRegistrationAPI_v2_Test {
    
  Static String restURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/v2/';
    
  public static testmethod void testRegisterPost() {
    System.debug('----> UNIT TEST: testRegisterPost: START');
    TestHelper.createData();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
    res.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
      
    String endpoint = restURL + 'citizenapp/user/register';
    req.requestURI = endpoint;
    req.requestBody = Blob.valueOf('{"fname": "Testy", "lname": "Test", "email": "testy@test.com", "phone": "5069999999", "password": "Testing1234"}');
    req.httpMethod = 'POST';
    RestContext.request = req;
      
    res.responseBody = Blob.valueOf('{"fname": "Testy", "lname": "Test", "email": "testy@test.com", "phone": "5069999999", "password": "Testing1234"}');
    res.statusCode = 200;
    RestContext.response = res;
      
    Test.startTest();
      Open311_AppRegistrationAPI_v2.registerCommunityUser('Testy', 'Test', 'testy@test.com', '5069999999', 'Testing1234');
    Test.stopTest();
  }

}