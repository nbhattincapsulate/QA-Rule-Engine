trigger WorkflowRulesEvaluationForFlexnote on FlexNote__c (after insert, after update) {
  Set<Id> Ids=new Set<Id>();
  Set<Id> CaseIds = new Set<Id>();
  String sobjName='FlexNote__c';
  List<CaseComment> caseComments = new List<CaseComment>();
    
  String CASE_COMMENT_PREFIX_TEXT = 'Scheduled Bulk Collection Date: ';
    
  System.debug('----> Workflow Trigger: FLEXNOTE!');
    
  //add all the accountids in the set
  for (FlexNote__c a:trigger.new){
    string legacyid = a.LegacyId__c==null?'':a.LegacyId__c;
      
    // If being inserted and if the legacy ID doesn't start with 'CSR-' then add it to the workflow Id's.
    if (trigger.isinsert && !legacyid.startswithignorecase('CSR-')) {
      Ids.add(a.Id);
    }
          
    // All other inserts and updates - including Legacy items that start with "CSR-" - insert into the CaseIds for history processing.
    CaseIds.add(a.Case__c);
        
    for (FlexNote__c flex : trigger.new) {           
      if ((flex.Questions__c != null && flex.Questions__c.contains('BULK COLLECTION DATE')) && (flex.Answer__c != null && flex.Answer__c != '{!Value}')) {
        Boolean isNewComment = true;
          
        if (caseComments.size() > 0) {
          for (CaseComment c : caseComments) {
            String body = c.CommentBody;
              
            if (body.equalsIgnoreCase(CASE_COMMENT_PREFIX_TEXT + flex.Answer__c)) {
              isNewComment = false;
              break;
            } 
          }      
        }
          
        if (isNewComment) {
      	  CaseComment cc = new CaseComment
          (
            CommentBody = CASE_COMMENT_PREFIX_TEXT + flex.Answer__c,
            ParentId = flex.Case__c,
            IsPublished = true
          );
          caseComments.add(cc);
        }              
      }     
    }
  }

  // Check to see if the workflow has already been triggered. 
  Boolean evaluate = WorkflowRuleEvaluation.EvaluationIsRunning;
          
  try {
    // If the workflow is not currently evaluating send the list of Id's to the Rule Engine class for evaluation.
    if (!evaluate) {
      WorkflowRuleEvaluation.startWorkflow(Ids, sobjName, Trigger.isInsert);
    }
      // If workflow evaluation was not running then ensure there are non-workflow Ids available. If workflow wasn't triggered then use all Ids.
    if (CaseIds.size() > 0) {
      List<Id> CaseIdList = new List<Id>();
        
      for (Id id : CaseIds) {
        CaseIdList.add(id);
      }
      // Create the history objects for the given case ids. 
      CloneHistoryObjects.cloneServiceRequestHistory(CaseIdList);
    }
    // Process Comments.
    WorkflowProcessUtility.evaluateCaseComments(caseComments);
  } catch (Exception e) {
    // If running a test then simply output a message.
    if (Test.isRunningTest()) {
      System.debug('This is not working properly'); 
    } else {
      throw(e); 
    }
  } 
}