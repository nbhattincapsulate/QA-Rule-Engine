@isTest
public class Console311_SearchControllerTest{
    
    public static testMethod void testController(){
        
        PageReference pageRef = Page.Console311_Search;
        Test.setCurrentPage(pageRef);
        Contact con=[SELECT Id FROM Contact LIMIT 1];
        Case caseRec=[SELECT Id FROM Case LIMIT 1]; 
        
        List<Id> fixedSearchResults= new List<Id>();
        fixedSearchResults.add(caseRec.Id);
        fixedSearchResults.add(con.id);
        Test.setFixedSearchResults(fixedSearchResults);
        
        Console311_SearchController controller=new Console311_SearchController();
        
        // Verify that object list is two
        System.assertEquals(2, controller.getObjectList().size());
        
        //Search for a word
        controller.searchString='Park';
        controller.doSearch();
        
        // Verify that map size is two
        System.assertEquals(2, controller.serachResults.size());
        
        //Assert case is size 1
        System.assertEquals(1, controller.serachResults.get('Case').size);
        
        //Assert contact is size 1
        System.assertEquals(1, controller.serachResults.get('Contact').size);
        
    }
    
    @testSetup static void createTestData() {
        
        //Create Contact
        Contact contact = New Contact(FirstName='Parker',LastName='Last', email='test@test.com',Phone='111111');
        insert contact;
        
        //Create Case
        ServiceRequestType__c serviceRequest=new ServiceRequestType__c(Name='Parking',Object__c='Case',Service_Name__c='Parking Meter Issue',Default_Status__c='New',Default_Priority__c='Standard',Default_Method__c='Phone',ContactRequired__c=true,ServiceLocationRequired__c=true,SR_Alert_Message__c='Test Message');
        insert serviceRequest;        
        
        Case caseRecord=new Case(Origin='Phone',subject='Parking Meter Repair',Status='New',ContactId=contact.Id,SRType__c=serviceRequest.Id);
        insert caseRecord;
        
        //Insert Custom Settings
        List<Console311Settings__c> csList=new List<Console311Settings__c>();
        
        Console311Settings__c cs = new Console311Settings__c();
        cs.name = 'ObjectsToSearch';
        cs.Value__c = 'Case;Contact';
        csList.add(cs);
        
        Console311Settings__c cs1 = new Console311Settings__c();
        cs1.name = 'FieldSetName';
        cs1.Value__c = 'DCConsoleSearchFieldset';
        csList.add(cs1);
        
        Console311Settings__c cs2 = new Console311Settings__c();
        cs2.name = 'Limit';
        cs2.Value__c = '25';
        csList.add(cs2);
        
        insert csList; 
        
    }
    
    
    
}