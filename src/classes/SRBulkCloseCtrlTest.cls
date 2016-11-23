@isTest
public class SRBulkCloseCtrlTest { 
  public static testmethod void testImportCSVFile() {
    TestHelper.createData();
    SRBulkClose_Config__c config = SRBulkClose_Config__c.getInstance();
    config.Max_Number_of_Records_to_Process__c = 2;
    upsert config;

    SRBulkCloseCtrl ctrl = new SRBulkCloseCtrl();

    List<Case> casesList = [Select Id, Service_Request_Number__c From Case];

    String csvString = '';

    for (Case c : casesList) {
      csvString += c.Service_Request_Number__c + ',Comments here\n';
    }
    Blob csvFileBlob = Blob.valueOf(csvString);

    ctrl.csvFileBody = csvFileBlob;
    ctrl.importCSVFile();
    System.assertEquals(0, ctrl.resultCaseWrapper.size());

    config.Max_Number_of_Records_to_Process__c = 1;
    upsert config;
    ctrl.importCSVFile();
    System.assertEquals(0, ctrl.resultCaseWrapper.size());
  }
}