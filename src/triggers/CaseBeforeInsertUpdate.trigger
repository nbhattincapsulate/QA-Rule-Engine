trigger CaseBeforeInsertUpdate on Case(before insert, before update, before delete) {

  if (Trigger.isDelete) {

    //here we need to update the servicer request history helper to mark the cases deleted
    list<String> caseNumbers = new List<String> ();
    for (Case c : Trigger.old)
    caseNumbers.add(c.casenumber);

    ServiceRequestHistoryHelper.updateCaseAsDeleted(caseNumbers);
    return;
  }

  if (Trigger.isUpdate) {
    for (Case c : Trigger.new) {
      // If the current updated case is NOT flagged as a duplicate, is NOT flagged as open, and the OLD version of the case is a DUPLICATE then proceed.
      if (c.Status != null && Trigger.oldMap.get(c.Id) != null && !c.Status.containsIgnoreCase('open') && Trigger.oldMap.get(c.Id).Status.equalsIgnoreCase('Duplicate (Opened)')) {
        System.debug('----> [CaseBeforeInsertUpdate] Case is a duplicate that was closed as a primary. Switching to proper closed status...');
        String closedStatus = '';
        // Store the old status to update the parent
        closedStatus = c.Status;
        // Convert the duplicate to the correct status.
        c.Status = 'Duplicate (Closed)';
        c.Previous_Status__c = closedStatus;
      }
    }
  }

  /*
   * This trigger sets Expected Bussiness Resolution date based on createdDate ,sla and Standard Bussines Hours values as inputs
   * Created by Devanand
   * Created date: 04-12-2014 
   */

  try {
    list<Id> serviceTypeId = new list<Id> ();
    for (case c : trigger.new) {
      serviceTypeId.add(c.SRType__c);
    }

    list<ServiceRequestType__c> serviceTypeList = [Select s.SLA__c, s.Name, s.Id From ServiceRequestType__c s where id In :serviceTypeId];

    // invoking method update the field ExpectedBusinessResolutionDate__c in case 
    ServiceRequestsHelper.setExceptedBussinessDateTime(trigger.new, serviceTypeList, trigger.isInsert);
  }
  catch(exception e) {
    system.debug('unable to complete set bussinessDate--' + e);
  }
}