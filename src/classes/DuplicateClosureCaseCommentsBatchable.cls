global class DuplicateClosureCaseCommentsBatchable implements Database.Batchable < SObject >, Database.Stateful {

  global Set<Id> caseIdsToDuplicateComments { get; set; }
  global String cronJobName { get; set; }
  global Map<String, List<Case>> parentCaseToDuplicateCases { get; set; }

  global DuplicateClosureCaseCommentsBatchable(Set<Id> caseIds, String cronJobName) {
    this.caseIdsToDuplicateComments = caseIds;
    this.cronJobName = cronJobName;
    //this.parentCaseToDuplicateCases = parentCaseToDuplicateCases;
  }

  /**
   * @description gets invoked when the batch job starts
   * @param context contains the job ID
   * @returns the record set as a QueryLocator object that will be batched for execution
   */
  global Database.QueryLocator start(Database.BatchableContext context) {
    return Database.getQueryLocator('Select Id, Address__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, SRType__r.Service_Name__c, Case_Closure_Comment__c From Case Where Id IN :caseIdsToDuplicateComments');
  }

  /**
   * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
   * @param context contains the job ID
   * @param scope contains the batch of records to process.
   */
  global void execute(Database.BatchableContext context, List<Case> scope) {
    System.debug('----> DuplicateClosureCaseCommentsBatchable -- START');
    //System.debug('----> [DuplicateClosureCaseCommentsBatchable] Parent Cases: ' + scope);
    //System.debug('----> [DuplicateClosureCaseCommentsBatchable] Parent Cases Size: ' + scope.size());
    List<CaseComment> ccToInsert = new List<CaseComment> ();

    for (Case c : scope) {
      List<Case> tempDuplicateCaseList = ServiceRequestsHelper.getDuplicateServiceRequestsByRelation(c.Id);
      //System.debug('----> [DuplicateClosureCaseCommentsBatchable][' + c.Id + '] Case Duplicates: ' + tempDuplicateCaseList);
      //System.debug('----> [DuplicateClosureCaseCommentsBatchable][' + c.Id + '] Case Duplicates Size: ' + tempDuplicateCaseList.size());
      Set<Id> duplicateCaseIds = new Set<Id> ();
      // Create a set of all the duplicate case Ids.
      for (Case tempC : tempDuplicateCaseList) {
        duplicateCaseIds.add(tempC.Id);
      }
      // Get the exisiting duplicate case's CaseComments to ensure we do not create any duplicates.
      List<CaseComment> duplicateExistingComments = [Select Id, CommentBody, IsPublished, ParentId From CaseComment Where ParentId IN :duplicateCaseIds AND IsPublished = true];

      for (Case duplicateC : tempDuplicateCaseList) {
        String ccDuplicateId = '';
        Boolean duplicateCaseCommentForCaseExists = false;
        System.debug('----> [DuplicateClosureCaseCommentsBatchable] Verifying that a duplicate case comment that is active doesn\'t exist...');
        // Loop through the duplicate existing comments and verify that a case comment doesn't already exist for this case with the same body text and is active.
        for (CaseComment cComment : duplicateExistingComments) {
          //System.debug('----> ['+ cComment.Id +'] CaseComment.ParentId: ' + cComment.ParentId + ' => Duplicate Id: ' + duplicateC.Id);
          //System.debug('----> ['+ cComment.Id +'] CaseComment.CommentBody: ' + cComment.CommentBody + ' => Duplicate.Case_Closure_Comment__c: ' + c.Case_Closure_Comment__c);
          if (cComment.ParentId == duplicateC.Id && cComment.CommentBody.equalsIgnoreCase(c.Case_Closure_Comment__c)) {
            ccDuplicateId = cComment.Id;
            duplicateCaseCommentForCaseExists = true;
            break;
          }
        } 
        // Create a new case comment.
        CaseComment cc = new CaseComment
        (
         CommentBody = c.Case_Closure_Comment__c,
         ParentId = duplicateC.Id,
         IsPublished = true
        );
        // If a duplicate case comment already exists then simply add the id to the new one to force the update date to be refreshed.
        if (duplicateCaseCommentForCaseExists) {
          System.debug('----> [DuplicateClosureCaseCommentsBatchable] Duplicate Case already contains an active comment with the same text. Updating exisiting comment to move it to the top of the list...');
          cc.Id = ccDuplicateId;
        } else {
          System.debug('----> [DuplicateClosureCaseCommentsBatchable] Generating new comment for duplicate [' + duplicateC.Id + '] of Parent Case [' + c.Id + ']...');
        }
        ccToInsert.add(cc);
      }
    }

    if (ccToInsert != null && ccToInsert.size() > 0) {
      //System.debug('----> ccToInsert: ' + ccToInsert);
      //System.debug('----> ccToInsert Size: ' + ccToInsert.size());
      upsert ccToInsert;
    }
  }

  /**
   * @description gets invoked when the batch job finishes. Place any clean up code in this method.
   * @param context contains the job ID
   */
  global void finish(Database.BatchableContext context) {
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                      TotalJobItems, CreatedBy.Email
                      FROM AsyncApexJob WHERE Id =
                      :context.getJobId()];

    System.debug('----> [DuplicateClosureCaseCommentsBatchable] Abort Job: ' + cronJobName);
    List<CronTrigger> cronTriggerList = [Select Id, CronJobDetail.Name From CronTrigger Where CronJobDetail.Name = :cronJobName Limit 1];

    for (CronTrigger t : cronTriggerList) {
      System.abortJob(t.Id);
    }
    System.debug('----> DuplicateClosureCaseCommentsBatchable -- FINISH');
  }
}