@isTest
public class Open311_TokenAPIResponseTest {
    public static testMethod void testAPIResponse() {
        TestHelper.createData();
        
        Case c = [Select Id, CaseNumber From Case Limit 1];
        //String jsonResp = '{\n"service_request_id": "' + c.CaseNumber + '",\n "token": "' + c.CaseNumber + '"\n}';
        String xmlResp = '<?xml version="1.0" encoding="UTF-8"?><service_requests><request><service_request_id>' + c.CaseNumber + '</service_request_id><token></token></request></service_requests>';
        
        System.assertNotEquals('', Open311_TokenAPIResponse.sendJSONResponse(c));
        System.assertEquals(xmlResp, Open311_TokenAPIResponse.sendXMLResponse(c));
    }
}