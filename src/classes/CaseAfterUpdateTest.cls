@isTest
public class CaseAfterUpdateTest {
  public static testMethod void testTrigger() {
    Test.startTest();
    TestHelper.createData();

    List<Contact> con = [Select Id From Contact Limit 1];
    List<ServiceRequestType__c> srType = [Select Id From ServiceRequestType__c Limit 1];

    if (con != null && con.size() == 1 && srType != null && srType.size() == 1) {
      Case c = new Case
      (
       Origin = 'Phone',
       Status = 'Open',
       ContactId = con[0].Id,
       SRType__c = srType[0].Id
      );
      insert c;

      Case c2 = new Case
      (
       Origin = 'Phone',
       Status = 'Duplicate (Opened)',
       ContactId = con[0].Id,
       SRType__c = srType[0].Id,
       ParentId = c.Id
      );
      insert c2;

      c2.Status = 'Voided';
      c2.Case_Closure_Comment__c = 'Closing Duplicate Case. This should close the primary.';
      c2.Reason = '1- Closed, issue resolved';
      upsert c2;

      Test.stopTest();

      Case updatedC = [Select Id, Status, Case_Closure_Comment__c, Reason From Case Where Id = :c.Id];
      System.assertEquals('Voided', updatedC.Status);
    }
  }
}