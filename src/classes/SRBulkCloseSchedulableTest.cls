@isTest
public class SRBulkCloseSchedulableTest {
  public static testMethod void testSRBulkCloseSchedulable() {
    Set<String> serviceRequestNumberList = new Set<String> ();
    Map<String, String> caseNumberToCommentMap = new Map<String, String> ();

    TestHelper.createData();
    List<Case> casesList = [Select Id, Service_Request_Number__c From Case];
    for (Case c : casesList) {
      serviceRequestNumberList.add(c.Service_Request_Number__c);
      caseNumberToCommentMap.put(c.Service_Request_Number__c, 'Testing');
    }

    Test.startTest();
    String query = 'Select Id, Case_Closure_Comment__c, Service_Request_Number__c From Case Where Service_Request_Number__c IN :serviceRequestNumberList Limit 10';
    // Get the cron timing for 60 Seconds from now.
    Datetime sysTime = System.now().addSeconds(30);
    String cronTiming = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
    // Create the initial batchname.
    DateTime dt = DateTime.now();
    String formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    String bulkBatchName = 'Bulk Close (' + UserInfo.getUserId() + '_' + formattedDt + ') - 1';
    // Iniliaze the first schedulable and batch.
    SRBulkCloseSchedulable bulkSchedulable = new SRBulkCloseSchedulable(query, serviceRequestNumberList, caseNumberToCommentMap);
    bulkSchedulable.batchableName = bulkBatchName;
    bulkSchedulable.resultCaseWrapper = new List<CaseStatusWrapper> ();
    System.schedule(bulkBatchName, cronTiming, bulkSchedulable);
    // Cover the other constructor.
    bulkSchedulable = new SRBulkCloseSchedulable(serviceRequestNumberList, caseNumberToCommentMap, '0', '0', '0', 1, UserInfo.getUserId());
    Test.stopTest();
  }
}