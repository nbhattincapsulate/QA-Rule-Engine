@isTest
public class ServiceRequestHistoryHelperTest {

    public static testMethod void testGetRequest() {
        TestHelper.createData();
        Service_Request_History__c srh = [Select Id From Service_Request_History__c Where IsClosed__c = false Limit 1];
        
        try {
          ServiceRequestHistoryHelper.getRequest(srh.Id);
        } catch (CustomException e) {
            System.assertEquals(APIConstants.NOT_FOUND, e.getMessage());
        }
    }
    
    public static testMethod void testUpdateCaseAsDeleted() {
       TestHelper.createData();
        
       List<Case> cases = [Select CaseNumber From Case];
       String[] caseNumbers = new List<String>();
       
        for(Case c : cases) {
          caseNumbers.add(c.CaseNumber);
        }
        
       ServiceRequestHistoryHelper.updateCaseAsDeleted(caseNumbers);
    }
}