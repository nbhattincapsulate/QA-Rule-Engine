@isTest
public class DuplicateClosureCommentsBatchableTest {
  public static testMethod void testDuplicateClosureCommentsBatchable() {
    TestHelper.createData();

    Test.startTest();

    List<ServiceRequestType__c> srType = [Select Id From ServiceRequestType__c Where Name = 'DMV19' Limit 1];
    List<Contact> con = [Select Id From Contact Limit 1];
    List<Case> parentCase = [Select Id From Case Where SRType__c = :srType[0].Id Limit 1];

    if (srType != null && srType.size() == 1 && con != null && con.size() == 1 && parentCase != null && parentCase.size() == 1) {
      Case c = new Case(Origin = 'Phone', Status = 'Duplicate (Open)', ContactId = con[0].Id, SRType__c = srType[0].Id, ParentId = parentCase[0].Id);
      insert c;

      CaseComment cc = new CaseComment(CommentBody = 'This is a comment', ParentId = parentCase[0].Id, isPublished = true);

      List<CaseComment> listOfNewComments = new List<CaseComment> ();
      listOfNewComments.add(cc);
      WorkflowProcessUtility.evaluateCaseComments(listOfNewComments);

      cc = new CaseComment(CommentBody = 'This is a comment', ParentId = parentCase[0].Id, isPublished = true);
      listOfNewComments = new List<CaseComment> ();
      listOfNewComments.add(cc);
      WorkflowProcessUtility.evaluateCaseComments(listOfNewComments);
    }

    Test.stopTest();

    List<Case> duplicateCaseList = [Select Id From Case Where ParentId = :parentCase[0].Id Limit 1];
    List<CaseComment> ccListAfterProcessing = [Select Id From CaseComment Where ParentId = :duplicateCaseList[0].Id];
    System.assertEquals(0, ccListAfterProcessing.size());
  }
}