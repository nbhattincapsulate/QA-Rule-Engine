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
private class SnowAttributeBatchTest {
	
	
	private static case serviceRequest;
	
	private static void createData(){
		
		Jurisdiction__c jur = new Jurisdiction__c();
		jur.Department__c = 'SNOW';
		jur.Agency__c ='SNOW';
		insert jur;
		
		ServiceRequestType__c serviceType = new ServiceRequestType__c();
		//serviceType.Service_Code__c='DE010215';
		serviceType.Service_Name__c='serviceTypeTest0215';
		serviceType.Jurisdiction__c=jur.Id;
		serviceType.Object__c='Case';
		serviceType.Name='Test02115';
		insert serviceType;
		
		/*
		FlexNoteQuestion__c fnQuestion = new FlexNoteQuestion__c();
		
		
		
		
		ServiceRequestTypeFlexNote__c serviceTypeFlexNotes = new ServiceRequestTypeFlexNote__c();
		serviceTypeFlexNotes.FlexNote_Question__c =;
		serviceTypeFlexNotes.Service_Request_Type__c=;
		*/
		
		Contact con=new Contact(FirstName='Mars',LastName='bruno', email='testContact@abc.com',Phone='1234567890');
        insert con;
		
	 	Case c=new Case(Origin='Phone',Status='New',ContactId=con.Id);
		c.SRType__c=serviceType.Id;
		c.XCOORD__c = '394674.32';
		c.YCOORD__c = '137648.32';
		c.Priority='Standard';
		c.Address__c='3100 N STREET NW,WASHINGTON,DC,USA,20007';
		//insert c;
		serviceRequest=c;
		//FlexNote__c fn = new FlexNote__c();
		
		
	}
	
    static testMethod void snowAttributesFetchTest() {
    	createData();
        // TO DO: implement unit test
        list<case>caseToInsertList =new list<case>();
        for(integer i=0;i<1;i++){
        	serviceRequest.Subject='Test'+i;
        	caseToInsertList.add(serviceRequest);
        }
        
       	Insert caseToInsertList;
       	
   		//Test.startTest();
       	SnowAttributesFetchBatch snowAttributeBatch =new SnowAttributesFetchBatch();
       	Database.BatchableContext BatchCont;
       	
       	snowAttributeBatch.start(BatchCont);
     	snowAttributeBatch.execute(BatchCont,caseToInsertList);
     	snowAttributeBatch.finish(BatchCont);
       	//Database.executeBatch(snowAttributeBatch,2);
   		//Test.stopTest();
       	
       	
       	
    }
}