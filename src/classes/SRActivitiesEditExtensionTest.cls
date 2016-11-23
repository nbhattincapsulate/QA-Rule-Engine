@IsTest
public class SRActivitiesEditExtensionTest {

    public static testmethod void testConstrutor(){
            
            TestHelper.createData();  
            
            
            Activity_Type__c t= new Activity_Type__c(Name='BULKUPDA');
            insert t;
            
            Activity_Outcomes__c outcome= new Activity_Outcomes__c(Name='Test',Activity_Type__c=t.id);
            insert  outcome;
            
            Test.startTest();
                    Case c = TestHelper.caseRrd;
                    
                    OUC_Activity__c activity = [Select Id FROM OUC_Activity__c WHERE Case__c=:c.Id LIMIT 1];
                    activity.activity_type__c = t.id;
                    
                    update activity;
                                    
                    ApexPages.standardController ct= new  ApexPages.standardController(activity);
                    SRActivitiesEditExtension ext = new SRActivitiesEditExtension(ct);
                    
            Test.stopTest();
            
    }

}