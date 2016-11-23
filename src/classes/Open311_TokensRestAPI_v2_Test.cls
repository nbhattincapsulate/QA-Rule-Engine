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
private class Open311_TokensRestAPI_v2_Test {
    
    Static String restURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/v2/';

    static testMethod void testGetServiceRequestId() {
        System.debug('----> UNIT TEST: testGetServiceRequestId: START');
        TestHelper.createData();
        String endpoint = restURL + 'tokens';
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', APIConstants.CONTENT_TYPE_JSON);
        req.requestURI = endpoint;
        req.httpMethod = 'GET';
        req.params.put('token', '');
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
          
        Test.startTest();
          Open311_TokensRestAPI_v2.getServiceRequestId();
          
          req.params.put('token', '1234');
          req.params.put('jurisdiction_id', '12345');
          RestContext.request = req;
        
          Open311_TokensRestAPI_v2.getServiceRequestId();
        
          req.params.remove('jurisdiction_id');
          Open311_TokensRestAPI_v2.getServiceRequestId();
        Test.stopTest();
    }
}