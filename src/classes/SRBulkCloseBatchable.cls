global class SRBulkCloseBatchable implements Database.Batchable < SObject >, Database.Stateful {

  public static Boolean isBulkCloseRunning { get; set; }
  public static Set<Id> duplicateCaseIdsToProcess { get; set; }

  private Set<Id> duplicateCaseIdsToProcessPrivate { get; set; }

  public String query;
  public String ownerId;
  public Integer counter;
  public Boolean isFinalRun;
  public String currentCronJobName { get; set; }

  public String numberOfErrors { get; set; }
  public String jobItemsProcessed { get; set; }
  public String totalJobItems { get; set; }

  public Set<String> serviceRequestNumberList { get; set; }
  public Map<String, String> caseNumberToCommentMap { get; set; }
  public List<CaseStatusWrapper> resultCaseWrapper { get; set; }

  global SRBulkCloseBatchable(String query, Integer counter, Boolean isFinalRun, String ownerId) {
    this.query = query;
    this.counter = counter;
    this.isFinalRun = isFinalRun;
    this.resultCaseWrapper = new List<CaseStatusWrapper> ();
    this.ownerId = ownerId;
  }

  /**
   * @description gets invoked when the batch job starts
   * @param context contains the job ID
   * @returns the record set as a QueryLocator object that will be batched for execution
   */
  global Database.QueryLocator start(Database.BatchableContext context) {
    Database.QueryLocator results;

    try {
      System.debug('----> query: ' + query);
      results = Database.getQueryLocator(query);
      // Check if the query returned no value or is null.  
      if (results == null || (results != null && !results.Iterator().hasNext())) {
        // If no results have been found from the query using ALL request ID's then inform the batch this is the final run.
        // The reason for this is that the query uses ALL of the ID's provided. If one is not found of what may be left then
        //   we no longer need to continue the process. It is possible for all of the ID's to not work.
        isFinalRun = true;      
      }
    } catch(Exception e) {
      System.debug('----> Error querying for SRBulkCloseBatchable: ' + e.getMessage());
      abortSelf(currentCronJobName, true);
      results = Database.getQueryLocator('');
    }
    return results;
  }

  /**
   * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
   * @param context contains the job ID
   * @param scope contains the batch of records to process.
   */
  global void execute(Database.BatchableContext context, List<Case> scope) {
    try {
      SRBulkCloseBatchable.isBulkCloseRunning = true;

      Map<String, String> caseIdToNumber = new Map<String, String> ();
      Set<String> retrievedCaseListToUpdate = new Set<String> ();
      // If the scope has value.
      if (scope != null && scope.size() > 0) {
        System.debug('----> [SRBulkCloseBatchable] Processing batch ' + counter + ' of cases to close.');
        // Loop through the cases and change the status along with updating the case closure comments.
        for (Case c : scope) {
          c.Status = 'Closed';
          c.Case_Closure_Comment__c = caseNumberToCommentMap.get(c.Service_Request_Number__c);
          // Map the ID to the number.
          caseIdToNumber.put(c.Id, c.Service_Request_Number__c);
          retrievedCaseListToUpdate.add(c.Service_Request_Number__c);
        }
        // Loop through the exisiting number list and verify if any of the numbers were not retrieved from the SOQL query.
        for (String srNumber : serviceRequestNumberList) {
          // If the retrieved case list does not contain a specified number then mark it as failed.
          if (!retrievedCaseListToUpdate.contains(srNumber)) {
            resultCaseWrapper.add(new CaseStatusWrapper(srNumber, caseNumberToCommentMap.get(srNumber), 'Failed'));
          }
        }
        // Update the case list.
        Database.SaveResult[] result = Database.Update(scope, false);
        // Loop through the results and create wrappers for the results. 
        for (Database.SaveResult saveResult : result) {
          String caseNumber = caseIdToNumber.get(saveResult.getId());

          // Loop through the exisiting wrapper list and ensure there are no duplicate entries. 
          List<CaseStatusWrapper> tempWrapperList = new List<CaseStatusWrapper> ();
          for (CaseStatusWrapper cWrap : resultCaseWrapper) {
            // If a duplicate entry has been added from a previous batch run then remove it with the live data version.
            if (!cWrap.srNumber.equalsIgnoreCase(caseNumber)) {
              tempWrapperList.add(cWrap);
            }
          }
          // Reset the wrapper list with the correct data.
          resultCaseWrapper = tempWrapperList;
          // Add the new wrapper.
          resultCaseWrapper.add(new CaseStatusWrapper(caseNumber, caseNumberToCommentMap.get(caseNumber), (saveResult.isSuccess() ? 'Success' : 'Failed')));
        }
        System.debug('----> [SRBulkCloseBatchable] Attempting to remove now closed cases from processor...');
        // Remove the now processed ID's from the set map for the next batch run.
        for (String idStr : caseIdToNumber.values()) {
          if (serviceRequestNumberList.contains(idStr)) {
            serviceRequestNumberList.remove(idStr);
          }
        }
        System.debug('----> [SRBulkCloseBatchable] serviceRequestNumberList after pruning: ' + serviceRequestNumberList);
        // Setting the static variable to a global to ensure use in the finish function.
        duplicateCaseIdsToProcessPrivate = SRBulkCloseBatchable.duplicateCaseIdsToProcess;
        System.debug('----> [SRBulkCloseBatchable] duplicateCaseIdsToProcessPrivate: ' + duplicateCaseIdsToProcessPrivate);
        System.debug('----> [SRBulkCloseBatchable] duplicateCaseIdsToProcess grabbed without static reference: ' + duplicateCaseIdsToProcess);
      } else {
        System.debug('----> [SRBulkCloseBatchable] There are no cases found. Aborting job.');
        isFinalRun = true;
        abortSelf(currentCronJobName, true);
      }
    } catch(Exception e) {
      System.debug('----> [SRBulkCloseBatchable] Error querying for SRBulkCloseBatchable: ' + e.getMessage());
      isFinalRun = true;
      abortSelf(currentCronJobName, true);
    }
  }

  /**
   * @description gets invoked when the batch job finishes. Place any clean up code in this method.
   * @param context contains the job ID
   */
  global void finish(Database.BatchableContext context) {
    // Get the ID of the AsyncApexJob representing this batch job
    // from Database.BatchableContext.
    // Query the AsyncApexJob object to retrieve the current job's information.
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                      TotalJobItems, CreatedBy.Email
                      FROM AsyncApexJob WHERE Id =
                      :context.getJobId()];

    try {
      System.debug('----> [SRBulkCloseBatchable] Checking for applicable Case Comment Ids to process.');
      // If there was a Duplicate Comment batch that needed to be scheduled, then schedule it.
      if (duplicateCaseIdsToProcessPrivate != null && duplicateCaseIdsToProcessPrivate.size() > 0) {
        System.debug('----> [SRBulkCloseBatchable] Case Id\'s found to be queued for Case Comment batch. Processing...');
        WorkflowProcessUtility.scheduleDuplicateCaseCommentBatch(duplicateCaseIdsToProcessPrivate);
      }
        
      // If we are on the final iteration of the batchable then send a success email.
      if (isFinalRun) {
        System.debug('----> [SRBulkCloseBatchable] Final run detected. Saving history to Salesforce...');
        // Generate a list of history objects for the batch.
        List<Bulk_Close__c> batchHistoryList = new List<Bulk_Close__c> ();
        for (CaseStatusWrapper cWrapper : resultCaseWrapper) {
          // Create a new history bulk_close__c object to save the rows results.
          batchHistoryList.add
          (
           new Bulk_Close__c(
                             Name = currentCronJobName,
                             Requester__c = (UserInfo.getUserId() != null ? UserInfo.getUserId() : ownerId),
                             Service_Request_Closure_Comments__c = cWrapper.comments,
                             Service_Request_Number__c = cWrapper.srNumber,
                             Status__c = cWrapper.saveStatus)
          );
        }
        // If history objects have been made then save them.
        if (batchHistoryList.size() > 0) {
          upsert batchHistoryList;
        }

        System.debug('----> [SRBulkCloseBatchable] Sending notification email to user...');
        // Send an email to inform a success.
        sendEmail(a, 'Batch Closure of Cases Successful');
      } else {
        // Copy over batachable information.
        numberOfErrors += a.NumberOfErrors;
        jobItemsProcessed += a.JobItemsProcessed;
        totalJobItems += a.TotalJobItems;
        counter++;
        // Generate a new batach name.
        String newBatchName = generateBatchableName();
        // Create a new schedulable with the current information.
        SRBulkCloseSchedulable bulkSchedule = new SRBulkCloseSchedulable(serviceRequestNumberList, caseNumberToCommentMap, numberOfErrors, jobItemsProcessed, totalJobItems, counter, ownerId);
        // Add the query and new batch name to the new version of the schedulable.
        bulkSchedule.queryStr = query;
        bulkSchedule.batchableName = newBatchName;
        bulkSchedule.resultCaseWrapper = resultCaseWrapper;
        // Prep the cron to run 60 Seconds from now.
        Datetime sysTime = System.now().addSeconds(10);
        String cronTiming = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        // Schedule the cron under the new batch name to run.
        System.schedule(newBatchName, cronTiming, bulkSchedule);
      }
      // Abort the current batch once complete.
      abortSelf(currentCronJobName, false);
    } catch(Exception e) {
      System.debug('----> [SRBulkCloseBatchable] Error querying for SRBulkCloseBatchable: ' + e.getMessage());
      abortSelf(currentCronJobName, a);
    }
  }

  private void abortSelf(String cronJobName, Boolean isFailure) {
    System.debug('----> [SRBulkCloseBatchable] Abort Job: ' + cronJobName);
    List<CronTrigger> cronTriggerList = [Select Id, CronJobDetail.Name From CronTrigger Where CronJobDetail.Name = :cronJobName Limit 1];

    for (CronTrigger t : cronTriggerList) {
      System.abortJob(t.Id);
    }
  }

  private void abortSelf(String cronJobName, AsyncApexJob a) {
    // Call the parent version to abort the job.
    abortSelf(cronJobName, true);
    // Send a failure email.
    sendEmail(a, 'Bulk Closure of Cases has Failed');
  }

  private String generateResultsEmailMessage(String statusHeaderMessage, Boolean isHtml, Boolean isTextAttachment) {
    String message = '';
    Integer numOfSucessfulUpdates = 0;
    // Find out how many wrappers were successful.
    for (CaseStatusWrapper wrapper : resultCaseWrapper) {
      if (wrapper.saveStatus.equalsIgnoreCase('Success')) {
        numOfSucessfulUpdates++;
      }
    }
    //Process the results wrapper into a usable html and plain text email.
    if (isHtml) {
      message += '<h2>' + statusHeaderMessage + '</h2></br></br>';
      message += '<p>A total of <b>' + numOfSucessfulUpdates + '</b> out of <b>' + resultCaseWrapper.size() + '</b> were closed successful.</p>';
      message += '<p>If you wish to see more details concerning your bulk request, please check Salesforce at your own convinece.</p>';
      /*message += '<hr><table border="0" cellpadding="10" cellspacing="0">';
        message += '<thead>';
        message += '<tr>';
        message += '<th>Case Id</th>';
        message += '<th>Case Closure Comments</th>';
        message += '<th>Update Status</th>';
        message += '</tr>';
        message += '</thead>';
        message += '<tbody>';
        for (CaseStatusWrapper caseWrapper : resultCaseWrapper) {
        message += '<tr>';
        message += '<td data-label="id"><span class="slds-truncate">' + caseWrapper.srNumber + '</span></td>';
        message += '<td data-label="comments"><span class="slds-truncate">' + caseWrapper.comments + '</span></td>';
        message += '<td data-label="status" style="text-align: center;"><span class="slds-truncate">' + caseWrapper.saveStatus + '</span></td>';
        message += '</tr>';
        }
        message += '</tbody>';
        message += '</table>';*/
    } else {
      message += statusHeaderMessage + ' \n';
      message += 'A total of ' + numOfSucessfulUpdates + ' out of ' + resultCaseWrapper.size() + ' were closed successful. \n';
      message += 'If you wish to see more details concerning your bulk request, please check Salesforce at your own convinece. \n';

      if (isTextAttachment) {
        for (CaseStatusWrapper caseWrapper : resultCaseWrapper) {
          message += '--------------------------------------------------- \n';
          message += 'Case Id: ' + caseWrapper.srNumber + ' \n';
          message += 'Case Closure Comments: ' + caseWrapper.comments + ' \n';
          message += 'Update Status: ' + caseWrapper.saveStatus + ' \n';
        }
      }
    }
    return message;
  }

  private void sendEmail(AsyncApexJob a, String bodyText) {
    // Send an email to the Apex job's submitter notifying of job completion.
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> toAddresses = new List<String> ();
    toAddresses.add(a.CreatedBy.Email);
    // Obtain all the Sys Admin emails that are flagged to recieve emails from the close batch. 
    // TODO: Add profile check for Sys Admin as well.
    List<User> adminEmailList = [Select Id, Email From User Where Batch_Close_Notifications_Enabled__c = true];
    for (User u : adminEmailList) {
      toAddresses.add(u.Email);
    }
    mail.setToAddresses(toAddresses);
    mail.setSubject('SR Bulk Close: ' + a.Status);
    mail.setPlainTextBody(generateResultsEmailMessage(bodyText, false, false));
    mail.setHtmlBody(generateResultsEmailMessage(bodyText, true, false));
    // Datetime for filename.
    DateTime dt = DateTime.now();
    String formattedDt = dt.format('yyyy-MM-dd\'T\'hh-mm-ss.SSS\'Z\'');
    // Create a text file attachment of the results.
    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    attach.setContentType('application/text');
    attach.setFileName('bulk_close_results_' + formattedDt + '.txt');
    attach.setInline(false);
    attach.Body = Blob.valueOf(generateResultsEmailMessage(bodyText, false, true));
    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
    // Send the email in a single request.
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }

  private String generateBatchableName() {
    DateTime dt = DateTime.now();
    String formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');
    return 'Bulk Close (' + ownerId + '_' + formattedDt + ') - ' + counter;
  }
}