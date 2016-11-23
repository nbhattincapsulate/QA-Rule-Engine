/**
 * ServiceReportsControllerTest
 * 
 * This controller will handle all the test methods for the ServiceReportsController.
 * @author Darkis
 */

@isTest
public class ServiceReportsControllerTest {

  public static void setup() {
    // Create the basic data structure.
    TestHelper.createData();
    // Fine tune the structure to match necessary components. 
    Jurisdiction__c jur = new Jurisdiction__c(Name = 'DPW', Agency__c = 'DPW');
    insert jur;
    jur = [Select Id From Jurisdiction__c Where Name = 'DPW'];
    // Update the ServiceRequestType with the new Jurisdiction.
    ServiceRequestType__c srt = TestHelper.serviceType1;
    srt.Jurisdiction__c = jur.Id;
    update srt;

    // Add the custom settings.
    SR_Reports_Config__c config = new SR_Reports_Config__c();
    config.Name = 'Version_1';
    config.List_Size__c = 20;
    config.Report_Limit__c = 10;
    insert config;
  }

  public static testMethod void testServiceReportsController() {
    // Setup 
    ServiceReportsControllerTest.setup();
    // Test the constructor.
    ServiceReportsController ctrl = new ServiceReportsController();
    System.assertEquals(2, ctrl.allCases.size());
  }

  public static testMethod void testServiceRequestChecked() {
    // Setup
    ServiceReportsControllerTest.setup();
    // Test the checkbox method.
    ServiceReportsController ctrl = new ServiceReportsController();
    // Set the page reference to the PDF Tab.
    PageReference page = new PageReference('/apex/ServiceReports');
    Test.setCurrentPage(page);
    // Put the pass in case Id that would normally be delivered by the page.
    ApexPages.currentPage().getParameters().put('caseId', TestHelper.caseRrd.Id);
    // Call to add to the list.
    ctrl.serviceRequestChecked();
    System.assertEquals(1, ctrl.selectedCaseIds.size());
    // Call to remove from list.
    ctrl.serviceRequestChecked();
    System.assertEquals(0, ctrl.selectedCaseIds.size());
    // Add 10 items to test the max limit.
    for (Integer i = 0; i <= 10; i++) {
      Case c = new Case(Origin = 'Phone', Status = 'New', ContactId = TestHelper.cont.Id, SRType__c = TestHelper.serviceType1.Id);
      insert c;
      c = [Select Id From Case Where Id = :c.Id];
      ApexPages.currentPage().getParameters().put('caseId', c.Id);
      // Call the request checked to add the values to the Id list.
      ctrl.serviceRequestChecked();
    }
    // Loop through all the messages and ensure the over 10 one is made.
    ApexPages.Message[] pageMessages = ApexPages.getMessages();
    System.assertNotEquals(0, pageMessages.size());
    // Check that the error message you are expecting is in pageMessages
    Boolean messageFound = false;

    for (ApexPages.Message message : pageMessages) {
      if (message.getSummary() == 'Only 10 items can be selected at once. Please remove one before attempting to add another.'
          && message.getSeverity() == ApexPages.Severity.WARNING) {
        messageFound = true;
      }
    }
    System.assert(messageFound);
  }

  public static testMethod void testGenerate() {
    // Setup
    ServiceReportsControllerTest.setup();
    // Test the checkbox method.
    ServiceReportsController ctrl = new ServiceReportsController();

    // Test the generate method.
    System.assertEquals(null, ctrl.generate());

    // Set the page reference to the PDF Tab.
    PageReference page = new PageReference('/apex/ServiceReports');
    Test.setCurrentPage(page);
    // Put the pass in case Id that would normally be delivered by the page.
    ApexPages.currentPage().getParameters().put('caseId', TestHelper.caseRrd.Id);
    // Add case to the selected Id's.
    ctrl.serviceRequestChecked();
    PageReference pge = ctrl.generate();
    System.assertEquals('/apex/ServiceReportPDF', pge.getUrl());
  }

  public static testMethod void testNavigationMethods() {
    // Setup
    ServiceReportsControllerTest.setup();
    // Test the checkbox method.
    ServiceReportsController ctrl = new ServiceReportsController();

    // Disable Next
    System.assertEquals(true, ctrl.getDisableNext());
    // Disable Previous
    System.assertEquals(true, ctrl.getDisablePrevious());
    // Total Pages
    System.assertEquals(1, ctrl.getTotalPages());
    // Page Number
    System.assertEquals(1, ctrl.getPageNumber());
    // Total Size
    System.assertEquals(2, ctrl.getTotal_size());

    // Add more than 20 cases for 2 pages.
    List<Case> cases = new List<Case> ();
    for (Integer i = 0; i <= 20; i++) {
      Case c = new Case(Origin = 'Phone', Status = 'New', ContactId = TestHelper.cont.Id, SRType__c = TestHelper.serviceType1.Id);
      cases.add(c);
    }
    insert cases;
    // Re-instantiate the controller to collect the total_size correctly.
    ctrl = new ServiceReportsController();
    System.assertEquals(23, ctrl.getTotal_size());

    // Next
    ctrl.Next();
    System.assertEquals(20, ctrl.getCounter());
    System.assertEquals(false, ctrl.limitReached);
    System.assertEquals(3, ctrl.allCases.size());
    // Previous
    ctrl.Previous();
    System.assertEquals(0, ctrl.getCounter());
    System.assertEquals(false, ctrl.limitReached);
    System.assertEquals(20, ctrl.allCases.size());
    // End
    ctrl.End();
    System.assertEquals(20, ctrl.getCounter());
    System.assertEquals(false, ctrl.limitReached);
    System.assertEquals(3, ctrl.allCases.size());
    // Beginning - Called again to ensure items are being reset. 
    ctrl.Beginning();
    System.assertEquals(0, ctrl.getCounter());
    System.assertEquals(false, ctrl.limitReached);
    System.assertNotEquals(0, ctrl.allCases.size());
    // Total Pages - Now that we have more than one.
    System.assertEquals(2, ctrl.getTotalPages());
  }

  public static testMethod void testClearDates() {
    // Setup
    ServiceReportsControllerTest.setup();
    // Test the checkbox method.
    ServiceReportsController ctrl = new ServiceReportsController();
    ctrl.daterangeFrom = '2015-10-2';
    ctrl.daterangeTo = '2015-10-2';
    ctrl.clearDates();
    System.assertEquals(null, ctrl.daterangeFrom);
    System.assertEquals(null, ctrl.daterangeTo);
  }

  public static testMethod void testReset() {
    // Setup
    ServiceReportsControllerTest.setup();
    // Test the checkbox method.
    ServiceReportsController ctrl = new ServiceReportsController();
    // Set the page reference to the PDF Tab.
    PageReference page = new PageReference('/apex/ServiceReports');
    Test.setCurrentPage(page);
    // Put the pass in case Id that would normally be delivered by the page.
    ApexPages.currentPage().getParameters().put('caseId', TestHelper.caseRrd.Id);

    ctrl.checkAllEnabled = true;
    ctrl.serviceRequestCheckAll();
    System.assertEquals(ctrl.allCasesSelected.size(), 2);
    ctrl.checkAllEnabled = false;
    ctrl.serviceRequestCheckAll();
    System.assertEquals(ctrl.allCasesSelected.size(), 0);

    // Call to add to the list.
    ctrl.serviceRequestChecked();
    System.assertEquals(1, ctrl.selectedCaseIds.size());
    // Test Mode methods.
    ctrl.allRequests();
    System.assertEquals('', ctrl.mode);
    ctrl.openRequestsOnly();
    System.assertEquals('Open', ctrl.mode);
    ctrl.closedRequestsOnly();
    System.assertEquals('Closed', ctrl.mode);
    // Test sort method.
    ctrl.toggleSortOrder();
    System.assertEquals('ASC', ctrl.sortColumnDirection);
    ctrl.toggleSortOrder();
    System.assertEquals('DESC', ctrl.sortColumnDirection);

    ctrl.daterangeFrom = '2015-05-21';
    ctrl.daterangeTo = '2015-05-22';
    ctrl.reset();
    System.assertEquals(1, ctrl.selectedCaseIds.size());
  }

  public static testmethod void testProcessClosingCasesFuture() {
    // Setup
    ServiceReportsControllerTest.setup();
    // Test the checkbox method.
    ServiceReportsController ctrl = new ServiceReportsController();
    // Set the page reference to the PDF Tab.
    PageReference page = new PageReference('/apex/ServiceReports');
    Test.setCurrentPage(page);
    // Put the pass in case Id that would normally be delivered by the page.
    ApexPages.currentPage().getParameters().put('caseId', TestHelper.caseRrd.Id);
    // Call to add to the list.
    ctrl.serviceRequestChecked();
    System.assertEquals(1, ctrl.selectedCaseIds.size());
    ctrl.closeSelectedCases();
    //Case tempCase = [Select Id, SR_Status__c From Case Where Id IN :ctrl.selectedCaseIds Limit 1];
    //System.assertEquals(tempCase.SR_Status__c, 'New');
  }

  public static testMethod void testServiceRequestCheckAll() {



  }
}