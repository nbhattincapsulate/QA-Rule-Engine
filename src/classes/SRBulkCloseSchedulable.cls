global class SRBulkCloseSchedulable implements Schedulable {

  public String ownerId { get; set; }
  public Integer counter { get; set; }
  public String queryStr { get; set; }
  public String batchableName { get; set; }
  public String numberOfErrors { get; set; }
  public String jobItemsProcessed { get; set; }
  public String totalJobItems { get; set; }
  public Set<String> serviceRequestNumberList { get; set; }
  public Map<String, String> caseNumberToCommentMap { get; set; }
  public List<CaseStatusWrapper> resultCaseWrapper { get; set; }

  global SRBulkCloseSchedulable(String query, Set<String> serviceRequestNumberList, Map<String, String> caseNumberToCommentMap) {
    this.queryStr = query;
    this.serviceRequestNumberList = serviceRequestNumberList;
    this.caseNumberToCommentMap = caseNumberToCommentMap;
    this.counter = 1;
    this.ownerId = UserInfo.getUserId();
  }

  global SRBulkCloseSchedulable(Set<String> serviceRequestNumberList, Map<String, String> caseNumberToCommentMap, String numOfErrors, String numOfItemsProcessed, String numOfTotalItems, Integer counter, String ownerId) {
    this.serviceRequestNumberList = serviceRequestNumberList;
    this.caseNumberToCommentMap = caseNumberToCommentMap;
    this.numberofErrors = numOfErrors;
    this.jobItemsProcessed = numOfItemsProcessed;
    this.totalJobItems = numOfTotalItems;
    this.counter = counter;
    this.ownerId = ownerId;
  }

  global void execute(SchedulableContext ctx) {
    try {
      // Construct the batch.
      SRBulkCloseBatchable srBulkBatch = new SRBulkCloseBatchable(queryStr, counter, (serviceRequestNumberList.size() <= 10 ? true : false), (UserInfo.getUserId() != null ? UserInfo.getUserId() : ownerId));
      // Add any remaining fields.
      srBulkBatch.caseNumberToCommentMap = caseNumberToCommentMap;
      srBulkBatch.serviceRequestNumberList = serviceRequestNumberList;
      srBulkBatch.numberOfErrors = numberOfErrors;
      srBulkBatch.jobItemsProcessed = jobItemsProcessed;
      srBulkBatch.totalJobItems = totalJobItems;
      srBulkBatch.currentCronJobName = batchableName;
      srBulkBatch.resultCaseWrapper = resultCaseWrapper;
      // Execute the batch.
      Id batchProcessId = Database.executeBatch(srBulkBatch);
    } catch(Exception e) {
      System.debug('----> Aborting Jobs due to error: ' + e.getMessage());
      abortJobs();
    }
  }

  private void abortJobs() {
    // Abort all jobs with this users ID present. 
    String likeConditional = 'Bulk Close (' + (UserInfo.getUserId() != null ? UserInfo.getUserId() : ownerId) + '%';
    List<CronTrigger> cronTriggerList = [Select Id, CronJobDetail.Name From CronTrigger Where CronJobDetail.Name LIKE :likeConditional];

    for (CronTrigger t : cronTriggerList) {
      System.abortJob(t.Id);
    }
  }
}