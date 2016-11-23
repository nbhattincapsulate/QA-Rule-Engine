trigger OUCActivityAfterUpdate on OUC_Activity__c(after update) {

    // TODO: Remove this reference and instead have the workflow eval be processed in a Queue format.
  WorkflowProcessUtility.initiateWorkflowEvaluation('OUC_Activity__c', Trigger.new, Trigger.isInsert);
  
  /*Database.DMLOptions opts = new Database.DMLOptions();
  opts.EmailHeader.triggerAutoResponseEmail = true;
  opts.EmailHeader.triggerOtherEmail = true;
  opts.EmailHeader.triggerUserEmail = true;

  List<CaseComment> caseComments = new List<CaseComment>();
  // If external comments were added then attach them as comments to the parent case object.
  for (OUC_Activity__c act : Trigger.new) {
    if (!String.isBlank(act.External_Comments__c) && !act.External_Comments__c.equalsIgnoreCase(Trigger.oldMap.get(act.Id).External_Comments__c)) {
      CaseComment cc = new CaseComment(
                                       CommentBody = act.External_Comments__c,
                                       ParentId = act.Case__c,
                                       IsPublished = true
      );
      cc.setOptions(opts);
      caseComments.add(cc);
    }
  }
  // Ensure that emails will be triggered for the owner of the case.
  insert caseComments;*/
  
}