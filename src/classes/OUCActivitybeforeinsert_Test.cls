@isTest 
public class OUCActivitybeforeinsert_Test{

static testMethod void testMethod1(){
    
    TestHelper.createData();
    
    Case c = [Select Id From Case Limit 1];
    
    OUC_Activity__c obj1 = new OUC_Activity__c ();
    obj1.Task_Code__c ='ABC';
    obj1.Case__c = c.Id;
    insert obj1;
    
    OUC_Activity__c obj2 = new OUC_Activity__c ();
    obj2.Task_Code__c ='REINSPEC';
    obj2.Case__c = c.Id;
    insert obj2;
    
    Activity_Type__c  activityObj = new Activity_Type__c(Name='REINSPEC');
    insert activityObj;
    Activity_Type__c  activityObj2 = new Activity_Type__c(Name='DEFAULT');
    insert activityObj2;
    
     OUC_Activity__c obj3 = new OUC_Activity__c ();
     obj3.Activity_Type__c =activityObj.Id;
     obj3.Case__c = c.Id;
     insert obj3;
     
     OUC_Activity__c obj4 = new OUC_Activity__c ();
     obj4.Task_Code__c ='ABC';
     obj4.Case__c = c.Id;
     obj3.Activity_Type__c =activityObj2.Id;
     insert obj4;
     
     OUC_Activity__c obj5 = new OUC_Activity__c ();
     obj5.Activity_Type__c =activityObj.Id;
     obj5.Case__c = c.Id;
     obj5.Task_Code__c ='REINSPEC';
     insert obj5;
}
}