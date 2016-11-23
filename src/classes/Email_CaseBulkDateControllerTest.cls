@isTest
public class Email_CaseBulkDateControllerTest {
  
  public static testMethod void testGetBulkScheduleDate() {
    TestHelper.createData();

    Email_CaseBulkDateController ctrl = new Email_CaseBulkDateController();

    List<Case> tempCaseList = [Select Id From Case Limit 1];

    if (tempCaseList != null && tempCaseList.size() == 1) {
      PageReference pageRef = Page.AgentConsolePge;
      System.Test.setCurrentPage(pageRef);
      System.currentPageReference().getParameters().put('parentId', tempCaseList.get(0).Id);  
        
      ctrl.getBulkScheduleDate();
    }
  }  
}