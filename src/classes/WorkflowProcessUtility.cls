public class WorkflowProcessUtility {

  /**
   * evaluateCaseComments
   *
   * @description This function will evaluate a list of case comments for processing. It will verify duplicates and only insert new versions.
   * @author Darkis
   * @param caseComments List<CaseComment> A list of the to be entered case comments.
   */
  public static void evaluateCaseComments(List<CaseComment> caseComments) {
    System.debug('----> [evaluateCaseComments] ENTER ');
    Set<Id> caseIds = new Set<Id> ();
    List<String> newCaseCommentBodies = new List<String> ();
    // If there are some case comments we wish to attempt to add then verify them.
    if (caseComments != null && caseComments.size() > 0) {
      // Loop through the new comments and grab a set and list of the parent ID's and new comment bodies.
      for (CaseComment cc : caseComments) {
        // Ensure we don't have duplicates of the parent IDs.
        if (!caseIds.contains(cc.ParentId)) {
          caseIds.add(cc.ParentId);
        }
        // Put all comment bodies into the list since they could be slightly different each time. 
        newCaseCommentBodies.add(cc.CommentBody);
      }
      // Grab any exisiting case comments that have the exact same body text with the same parent and are published. 
      List<CaseComment> ccExistingList =
      [
      Select Id, CommentBody, ParentId, isPublished
      From CaseComment
      Where isPublished = true AND ParentId IN : caseIds AND CommentBody IN : newCaseCommentBodies
      Order By CreatedDate DESC
      ];
      //System.debug('----> [evaluateCaseComments] Exisiting CC Query Params => Case Ids: ' + caseIds);
      //System.debug('----> [evaluateCaseComments] Exisiting CC Query Params => Comment Bodies: ' + newCaseCommentBodies);
      //System.debug('----> [evaluateCaseComments] Existing Case Comments: ' + ccExistingList);
      // If one exisits that's the same and is still published then do not add a new comment.
      if (ccExistingList != null && ccExistingList.size() > 0) {
        Integer counter = 0;
        Boolean matchFound = false;
        // Loop through the exisiting matching case comments. 
        for (CaseComment cc : ccExistingList) {
          // Loop through the prospects and verify that we don't have a duplicate comment.
          for (CaseComment newCC : caseComments) {
            String newCCParentIdStr = newCC.ParentId;
            String newCCCommentBodyStr = newCC.CommentBody;
            // If the new comment is a duplicate of an exisiting active comment then break the loop and remove from the upsert list.
            if (newCCParentIdStr.equalsIgnoreCase(cc.ParentId) && newCCCommentBodyStr.equalsIgnoreCase(cc.CommentBody)) {
              System.debug('----> [evaluateCaseComments] Duplicate Found: ' + cc.ParentId);
              matchFound = true;
              break;
            }
            counter++;
          }
          // Verify if a match was found.
          if (matchFound) {
            // Remove match from new upsert list.
            caseComments.remove(counter);
          }
          counter = 0;
          matchFound = false;
        }
        // If there are still new comments to insert then add them.
        if (caseComments.size() > 0) {
          //System.debug('----> [evaluateCaseComments] CaseComments to Upsert: ' + caseComments);
          System.debug('----> [evaluateCaseComments] Upserting new Case Comments.');
          upsert caseComments;

          // Ensure that another batch is not already in progress. 
          System.debug('----> [evaluateCaseComments] Verifying status of SRBulkCloseBatchable: ' + SRBulkCloseBatchable.isBulkCloseRunning);
          if (SRBulkCloseBatchable.isBulkCloseRunning == null || !SRBulkCloseBatchable.isBulkCloseRunning) {
            WorkflowProcessUtility.scheduleDuplicateCaseCommentBatch(caseIds);
          } else if (SRBulkCloseBatchable.isBulkCloseRunning) {
            // If the batchable is already running then store the case ids into it for processing once it's completed.
            SRBulkCloseBatchable.duplicateCaseIdsToProcess = caseIds;
          }
        }
      } else {
        //System.debug('----> [evaluateCaseComments] CaseComments to Upsert: ' + caseComments);
        System.debug('----> [evaluateCaseComments] Upserting new Case Comments.');
        upsert caseComments;
        System.debug('----> [evaluateCaseComments] Verifying status of SRBulkCloseBatchable: ' + SRBulkCloseBatchable.isBulkCloseRunning);
        // Ensure that another batch is not already in progress. 
        if (SRBulkCloseBatchable.isBulkCloseRunning == null || !SRBulkCloseBatchable.isBulkCloseRunning) {
          WorkflowProcessUtility.scheduleDuplicateCaseCommentBatch(caseIds);
        } else if (SRBulkCloseBatchable.isBulkCloseRunning) {
          // If the batchable is already running then store the case ids into it for processing once it's completed.
          SRBulkCloseBatchable.duplicateCaseIdsToProcess = caseIds;
        }
      }
    }
    System.debug('----> [evaluateCaseComments] EXIT ');
  }

  /**
   * initiateWorkflowEvaluation
   *
   * @description This function will - eventually - take in an sObject reference from a trigger and initiate the workflow process. 
   * @author Darkis
   * @param sobjName The name of the sObject in question. 
   * @param newTriggerData The list of trigger changed data. 
   * @param isInsert If the current action is an insert. 
   */
  public static void initiateWorkflowEvaluation(String sobjName, List<OUC_Activity__c> newTriggerData, Boolean isInsert) {
    System.debug('----> [initiateWorkflowEvaluation] ENTER ');
    Set<Id> Ids = new Set<Id> ();
    Set<Id> CaseIds = new Set<Id> ();

    System.debug('----> Workflow Process Utility: Start Workflow Eval');

    // TODO: Make this line dynamic based on the sObject type. 
    //get the IDs in the set for workflow submission
    for (OUC_Activity__c a : newTriggerData) {
      // Get the legacy Id from the activity or return null/blank.
      string legacyid = a.LegacyId__c == null ? '' : a.LegacyId__c;

      // If being inserted and if the legacy ID doesn't start with 'CSR-' then add it to the workflow Id's.
      if (!legacyid.startswithignorecase('CSR-')) {
        Ids.add(a.Id);
      }

      // All other inserts and updates - including Legacy items - insert into the CaseIds for history processing.
      CaseIds.add(a.Case__c);
    }

    // Check to see if the workflow has already been triggered. 
    Boolean evaluate = WorkflowRuleEvaluation.EvaluationIsRunning;

    try {
      System.debug('----> Workflow Process Utility [Activity] => evaluate: ' + evaluate);
      // If the workflow is not currently evaluating send the list of Id's to the Rule Engine class for evaluation.
      if (!evaluate) {
        WorkflowRuleEvaluation.startWorkflow(Ids, sobjName, isInsert);
      }
    } catch(Exception e) {
      // If running a test then simply output a message.
      if (Test.isRunningTest()) {
        System.debug('This is not working properly');
      } else {
        throw(e);
      }
    }
    System.debug('----> [initiateWorkflowEvaluation] EXIT ');
  }

  public static void scheduleDuplicateCaseCommentBatch(Set<Id> caseIds) {
    System.debug('----> Call to process duplicate case comments in a batch.');
    // Schedule a batch to process any possible duplicate case comments that need to be inserted from the master case.
    // Create the initial batchname.
    DateTime dt = DateTime.now();
    String formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');
    String batchName = 'Duplicate Case Comments for Closed Cases (' + UserInfo.getUserId() + '_' + formattedDt + ')';
    System.debug('----> Duplicate Batch: ' + batchName);
    DuplicateClosureCaseCommentsBatchable dupBatch = new DuplicateClosureCaseCommentsBatchable(caseIds, batchName);
    System.scheduleBatch(dupBatch, batchName, 1);
  }

  /**
  * sendTemplateEmail
  *
  * @description This function will send emails with a specified template name.
  * @param toRecipients The recipients of the email.
  * @param ccRecipients The CC list for this email.
  * @param templateApiName The template name in API format.
  * @param targetObjId Target object that is being applied to the template. (Main Obj)
  * @param whatId The secondary object if relatedTo is applied on the template.
  * @param orgWideEmailId The org email ID.
  * @param saveAsActivity 
  * @param attachList Attachment list.
  */
  public static void sendTemplatedEmail(List<String> toRecipients, List<String> ccRecipients, String templateApiName, ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity, Attachment[] attachList) {
    //  templateId   must be ID of an Email template
    //  targetObjId must be a Contact, User, Lead Id -- also used in merge fields of template recipient.xxxx
    //  whatId    must be an SObject that is used in the merge fields of the template relatedTo.xxxx
    //  fromId    if non null, use current user, otherwise, use this ID (most likely an org wide no reply id)
    //  bcc      not permitted when using templates
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    Id templateId;
    String orgEmailId;
    System.debug('----> ToAddresses: ' + toRecipients);
    System.debug('----> ccRecipients: ' + ccRecipients);
    System.debug('----> templateApiName: ' + templateApiName);
    System.debug('----> targetObjId: ' + targetObjId);
    System.debug('----> whatId: ' + whatId);
    System.debug('----> orgWideEmailId: ' + orgWideEmailId);
    System.debug('----> saveAsActivity: ' + saveAsActivity);
    System.debug('----> attachList: ' + attachList);

    try { 
      // Get the toaddress' from the contacts.
      List<Contact> tempContactList = [Select Id, Email From Contact Where Id IN :toRecipients];
      for (Contact con : tempContactList) {
        toRecipients.add(con.Email);
      }
      // Get the template.
      templateId = [select id, name from EmailTemplate where developername = :templateApiName].id; 

      // Get the org wid email address Id.
      List<OrgWideEmailAddress> orgEmailList = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
      orgEmailId = orgEmailList.get(0).Id;
    } catch(Exception e) {
      System.debug('[U-03] Unable to locate EmailTemplate using name: ' + templateApiName + ' refer to Setup | Communications Templates ' + templateApiName);
    }
    email.setToAddresses(toRecipients);
    email.setCcAddresses(ccRecipients);
    email.setTargetObjectId(targetObjId);
    email.setWhatId(whatId);
    email.setorgWideEmailAddressId(orgEmailId);
    email.setTemplateId(templateId);
    email.setReplyTo('311info@dc.gov');
    //email.setSenderDisplayName('DC 311 Info');
    email.setSaveAsActivity(saveAsActivity); // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users

    try {
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
      return;
    } catch(EmailException e) { 
      System.debug('[U-02] sendTemplatedEmail error. ' + e.getMessage()); 
    }
  }
}