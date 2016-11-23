@isTest
public class OUCActivityAfterUpdateTest { 
  public testMethod static void testTrigger() {
    TestHelper.createData();

    Case c = [Select Id From Case Limit 1];
    
    OUC_Activity__c oucActivity = new OUC_Activity__c (
      Task_Code__c = 'ABC',
      Case__c = c.Id
    );
    insert oucActivity;

    oucActivity.External_Comments__c = 'This is a comment. We do what we must, because, we can.';
    oucActivity.Status__c = 'Completed';
    oucActivity.Outcome__c = 'Closed, no action required';
    update oucActivity;

    CaseComment cc = [Select Id, CommentBody From CaseComment Where ParentId = :c.Id];
    System.assertEquals('This is a comment. We do what we must, because, we can.', cc.CommentBody);
  }
}