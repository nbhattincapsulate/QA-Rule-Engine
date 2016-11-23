@isTest
public class Console311_LookupControllerTest {
  @testSetup static void setup() {
    
  }

  public static testMethod void testConstructor() {
    Console311_LookupControllerTest.pageSetup();
    // Call the constructor.
    Console311_LookupController ctrl = new Console311_LookupController();
    System.assertEquals(ctrl.formattedSortName, 'Service Request Number  ');
  }

  public static testMethod void testQuery() {
    Console311_LookupControllerTest.pageSetup();
    Console311_LookupController ctrl = new Console311_LookupController();
    ctrl.sObjectName = null;
    System.assertEquals(null, ctrl.query());
  }

  private static void pageSetup() {
    // Setup an instance of the page. 
    PageReference page = new PageReference('Page.Console311_Lookup');
    Test.setCurrentPageReference(page);
    // Set the get params for the page.
    System.currentPageReference().getParameters().put('sobject', 'Case');
    System.currentPageReference().getParameters().put('sortfield', 'Service_Request_Number__c');
  }
}