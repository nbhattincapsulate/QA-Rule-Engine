public class SRBulkCloseCtrl {
  public Blob csvFileBody { get; set; }
  public String csvAsString { get; set; }
  public String[] csvFileLines { get; set; }
  public List<Case> caseList { get; set; }
  public List<CaseStatusWrapper> resultCaseWrapper { get; Set; }

  public SRBulkCloseCtrl () {

  }

  public void importCSVFile() {
    try {
      SRBulkClose_Config__c config = SRBulkClose_Config__c.getInstance();

      csvFileLines = new String[] { };
      caseList = New List<Case> ();
      resultCaseWrapper = new List<CaseStatusWrapper> ();
      Set<String> retrievedCaseListToUpdate = new Set<String> ();
      Set<String> serviceRequestNumberList = new Set<String> ();
      Map<String, String> caseNumberToCommentMap = new Map<String, String> ();
      Map<String, String> caseIdToNumber = new Map<String, String> ();

      // Move the file body into a string. 
      csvAsString = csvFileBody.toString();
      // Split the CSV lines.
      /*csvFileLines = csvAsString.split('\n');
      // Loop through the lines of the CSV and process the item.
      for (Integer i = 0; i < csvFileLines.size(); i++) {
        // Get the record data to be updated.
        String[] csvRecordData = csvFileLines[i].split(',');
        // Get the object params to process.
        serviceRequestNumberList.add(csvRecordData[0]);
        caseNumberToCommentMap.put(csvRecordData[0], csvRecordData[1]);
      }*/

      List<List<String>> parsedCSVResults = WorkflowRuleUtils.parseCSV(csvAsString);

      for (List<String> csvRow : parsedCSVResults) {
        serviceRequestNumberList.add(csvRow.get(0));
        caseNumberToCommentMap.put(csvRow.get(0), csvRow.get(1));
      }

      if (config.Max_Number_of_Records_to_Process__c <= 1000 && serviceRequestNumberList.size() <= config.Max_Number_of_Records_to_Process__c) {
        String query = 'Select Id, Case_Closure_Comment__c, Service_Request_Number__c From Case Where Service_Request_Number__c IN :serviceRequestNumberList Limit 5';
        // Get the cron timing for 60 Seconds from now.
        Datetime sysTime = System.now().addSeconds( 30 );
        String cronTiming = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        // Create the initial batchname.
        DateTime dt = DateTime.now();
        String formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');
        String bulkBatchName = 'Bulk Close (' + UserInfo.getUserId() + '_' + formattedDt + ') - 1';
        // Iniliaze the first schedulable and batch.
        SRBulkCloseSchedulable bulkSchedulable = new SRBulkCloseSchedulable(query, serviceRequestNumberList, caseNumberToCommentMap);
        bulkSchedulable.batchableName = bulkBatchName;
        bulkSchedulable.resultCaseWrapper = resultCaseWrapper;
        System.schedule(bulkBatchName, cronTiming, bulkSchedulable);
        // Inform the user of the process.
        ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.severity.INFO, 'CSV Uploaded Successfully. You will be notified by email with the status of your request once completed.');
        ApexPages.addMessage(infoMessage);
      } else {
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.WARNING, 'Case Limit Exceeded. CSV contains more than the ' + Integer.valueOf(config.Max_Number_of_Records_to_Process__c) + ' case(s) allowed per process.');
        ApexPages.addMessage(errorMessage);
      }
    } catch(Exception e) {
      ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured. Please ensure that all CSV data is formatted correctly with the service request number and comment.');
      ApexPages.addMessage(errorMessage);
      System.debug('----> Error: ' + e.getMessage());
    }
  }
}