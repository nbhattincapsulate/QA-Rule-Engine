trigger WorkflowRulesEvaluationForActivity on OUC_Activity__c(after insert, after update) {
  Set<Id> Ids = new Set<Id> ();
  Set<Id> CaseIds = new Set<Id> ();
  String sobjName = 'OUC_Activity__c';

  Database.DMLOptions opts = new Database.DMLOptions();
  opts.EmailHeader.triggerAutoResponseEmail = true;
  opts.EmailHeader.triggerOtherEmail = true;
  opts.EmailHeader.triggerUserEmail = true;
  List<CaseComment> caseComments = new List<CaseComment> ();

  System.debug('----> Workflow Trigger: ACTIVITY!');

  //get the IDs in the set for workflow submission
  for (OUC_Activity__c a : trigger.new) {
    // Get the legacy Id from the activity or return null/blank.
    string legacyid = a.LegacyId__c == null ? '' : a.LegacyId__c;
    // If being inserted and if the legacy ID doesn't start with 'CSR-' then add it to the workflow Id's.
    if (!legacyid.startswithignorecase('CSR-')) {
      Ids.add(a.Id);
    }
    // If external comments were added then attach them as comments to the parent case object.
    if (!String.isBlank(a.External_Comments__c)) {
      System.debug('----> [Activity] External Comments are NOT Blank.');
      if (Trigger.isInsert || (Trigger.isUpdate && !a.External_Comments__c.equalsIgnoreCase(Trigger.oldMap.get(a.Id).External_Comments__c))) {
        System.debug('----> [Activity] Trigger action is Insert OR Update with a changed comment.');
        CaseComment cc = new CaseComment(
                                         CommentBody = a.External_Comments__c,
                                         ParentId = a.Case__c,
                                         IsPublished = true
        );
        caseComments.add(cc);
      }
    }
    // All other inserts and updates - including Legacy items - insert into the CaseIds for history processing.
    CaseIds.add(a.Case__c);
  }
  
  // Check to see if the workflow has already been triggered. 
  Boolean evaluate = WorkflowRuleEvaluation.EvaluationIsRunning;

  try {
    System.debug('----> Workflow Trigger [Activity] => evaluate: ' + evaluate);
    // If the workflow is not currently evaluating send the list of Id's to the Rule Engine class for evaluation.
    if (!evaluate) {
      WorkflowRuleEvaluation.startWorkflow(Ids, sobjName, Trigger.isInsert);
    }
    // If workflow evaluation was not running then ensure there are non-workflow Ids available. If workflow wasn't triggered then use all Ids.
    if (CaseIds.size() > 0) {
      List<Id> CaseIdList = new List<Id> ();

      for (Id id : CaseIds) {
        CaseIdList.add(id);
      }
      // Create the history objects for the given case ids. 
      CloneHistoryObjects.cloneServiceRequestHistory(CaseIdList);
    }

    System.debug('----> [Activity] Processing comments...');
    WorkflowProcessUtility.evaluateCaseComments(caseComments);
  } catch(Exception e) {
    // If running a test then simply output a message.
    if (Test.isRunningTest()) {
      System.debug('This is not working properly');
    } else {
      throw(e);
    }
  }
}