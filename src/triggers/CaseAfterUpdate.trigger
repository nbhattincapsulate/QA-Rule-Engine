trigger CaseAfterUpdate on Case(after update) {
  Boolean isReady = false;
  System.debug('----> Workflow Trigger [CaseAfterUpdate]: CASE!');

  if (Trigger.isUpdate) {
    Map<String, Map<String, String>> parentIdToCloseStatusMap = new Map<String, Map<String, String>> ();
    List<Case> currentCasesToUpdateList = new List<Case> ();

    for (Case c : Trigger.new) {
      // If the current case has been: 
      //   1. Had it's previous status set from the BEFORE trigger. 
      //   2. Had it's status set to: Duplicate (Closed).
      //   3. The old version of the Case was: Duplicate (Opened)
      if ((c.Previous_Status__c != null && !c.Previous_Status__c.equalsIgnoreCase('Duplicate (Closed)')) && c.Status.equalsIgnoreCase('Duplicate (Closed)') && Trigger.oldMap.get(c.Id).Status.equalsIgnoreCase('Duplicate (Opened)')) {
        // Store the old status to update the parent
        String closedStatus = c.Previous_Status__c;

        if (c.ParentId != null) {
          System.debug('----> Parent detected. Mapping parent with new status and comments...');
          // Add the new parent ID to the mapping with the matching closed status.
          parentIdToCloseStatusMap.put(c.ParentId, new Map<String, String> { 'Status' => closedStatus, 'Comment' => c.Case_Closure_Comment__c, 'Reason' => c.Reason });
        }
      }
    }
    // If there are some parent cases to update then grab them and process the queue.
    if (parentIdToCloseStatusMap != null && parentIdToCloseStatusMap.size() > 0) {
      System.debug('----> Parent case updates discovered. Processing status and comment changes...');
      List<Case> parentCases = [Select Id, Status, Case_Closure_Comment__c, IsClosed From Case Where Id IN :parentIdToCloseStatusMap.keySet()];

      for (Case pCase : parentCases) {
        System.debug('----> Processing parent case [' + pCase.Id + ']...');
        System.debug('----> Parent case map results [' + pCase.Id + ']: ' + parentIdToCloseStatusMap.get(pCase.Id));
        if (parentIdToCloseStatusMap.containsKey(pCase.Id) && !pCase.IsClosed) {
          pCase.Status = parentIdToCloseStatusMap.get(pCase.Id).get('Status');
          pCase.Case_Closure_Comment__c = parentIdToCloseStatusMap.get(pCase.Id).get('Comment');
          pCase.Reason = parentIdToCloseStatusMap.get(pCase.Id).get('Reason');
        }
      }
      System.debug('----> Updating parent cases with new properties.');
      upsert parentCases;
    }
  }
}