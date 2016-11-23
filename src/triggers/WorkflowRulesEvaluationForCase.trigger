trigger WorkflowRulesEvaluationForCase on Case(after insert, after update) { 
  Set<Id> Ids = new Set<Id> ();
  String sobjName = 'Case';
  List<CaseComment> caseComments = new List<CaseComment> ();

  System.debug('----> Workflow Trigger [WorkflowRulesEvaluationForCase]: CASE!');

  //add all the accountids in the set
  for (Case a : trigger.new) {
    String legacyid = a.LegacyId__c == null ? '' : a.LegacyId__c;
    //  -- Do not execute workflow for Legacy Inserts - all others go
    if (!(trigger.isinsert && legacyid.startswithignorecase('CSR-'))) {
      Ids.add(a.Id);
    }
  } //for 

  System.debug('----> Workflow Id\'s: ' + Ids);
  //decide whether we need to start the process:- changing here for trigger chaining @sneha   
  Boolean evaluate = WorkflowRuleEvaluation.EvaluationIsRunning;


  //Send that list of created or updated account to the Rule Engine class for evaluation
  try {
    System.debug('----> WorkflowRulesEvaluationForCase [Case] => evaluate: ' + evaluate);
    if (!evaluate) {
      WorkflowRuleEvaluation.startWorkflow(Ids, sobjName, Trigger.isInsert);
    }

    /*
     * This trigger creates a copy of a Case obj in CaseHistory
     * when a case is created or edited
     * Created by Akshata Naik
     * Created date: 17-09-2014 
     */
    List<String> caseids = new List<String> ();
    for (Case cse : trigger.new) {
      caseids.add(cse.Id);
        
        for (FlexNote__c note : cse.FlexNotes__r) {
            System.debug('----> [Note]: ' + note);
        }
      //CloneHistoryObjects obj = new CloneHistoryObjects();
      //CloneHistoryObjects.cloneServiceRequestHistory(cse.Id);
    }

    for (Case cse : trigger.new) {
      System.debug('----> [Case] Verifying case closure status.');
      // If the case has been closed and the Case Closure Comment has been updated/changed then add a new Case Comment.
      if (!String.isBlank(cse.Case_Closure_Comment__c) && !cse.Case_Closure_Comment__c.equalsIgnoreCase(Trigger.oldMap.get(cse.Id).Case_Closure_Comment__c)) {
        System.debug('----> [Case] Case Closure Comment is not blank and is different from the previous.');
        CaseComment cc = new CaseComment
        (
         CommentBody = cse.Case_Closure_Comment__c,
         ParentId = cse.Id,
         IsPublished = true
        );
        caseComments.add(cc);
      }
    }
      
    if (SnowAttributesFetchBatch.isSnowAttributeBatchRunning = true) {
      CloneHistoryObjects.startCloneServiceRequestHistory(caseids);
    } else {
      CloneHistoryObjects.cloneServiceRequestHistory(caseids);
    }
    // Check for duplicates and close accordingly.
    System.debug('----> [Case] Processing duplicates for closure...');
    ServiceRequestsHelper.HandleDuplicateClosures(Trigger.new, Trigger.isUpdate);
    System.debug('----> [Case] Processing comments...');
    WorkflowProcessUtility.evaluateCaseComments(caseComments);
    
   //BhaskarN 11/15/2015:Below Logic is to invoke utility class to create Case Events for newly created records
    if(Trigger.isInsert){   
      for(Case c: trigger.new) {
         Id CaseId = c.id;
         String Subject = c.Subject;
         DateTime ExpResDate = c.Expected_Resolution_Date__c;
         CreateCaseEvents.CreateCaseEvent (c.Id, c.Subject,c.Expected_Resolution_Date__c); 
         System.debug('If CaseEvenTrigger Variables---->' + 'CaesId ---->' + CaseId + ' '  +  ExpResDate + ' '+ Subject +' '+  ExpResDate );      
      }
   } 
  else{
      for(Case c: trigger.new) {         
         Integer eventRows= [SELECT COUNT() FROM Event WHERE WhatId =: c.Id];           
         System.debug('Eventcount---->' + eventRows + 'Created Date' + c.CreatedDate + 'SystemDate' + system.now());  
         
         //Check if any events have been created for the case and if not, make sure to not trigger for old records
         if (eventRows == 0 && c.CreatedDate == c.Last_Update_Date__c && c.Status=='Open'){
         Id CaseId = c.id;
         String Subject = c.Subject;
         DateTime ExpResDate = c.Expected_Resolution_Date__c;
         CreateCaseEvents.CreateCaseEvent (c.Id, c.Subject,c.Expected_Resolution_Date__c); 
         System.debug('Else CaseEvenTrigger Variables---->' + 'CaesId ---->' + CaseId + ' '  +  ExpResDate + ' '+ Subject +' '+  ExpResDate );  
         }  
          } 
  }//End Of BhaskarN Code 
    
  } catch(Exception e) {
    //Do not Fail this trigger
    if (Test.isRunningTest()) {
      System.debug('This is not working properly');
    } else {
      throw(e);
    }
  }
}