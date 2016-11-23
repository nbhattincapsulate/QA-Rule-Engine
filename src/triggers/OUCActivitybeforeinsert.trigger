trigger OUCActivitybeforeinsert on OUC_Activity__c(before insert, before update, before delete)
{
  // Handle Deletes to update history
  if (Trigger.isDelete) {

    //here we need to collect the servicer request history helper to mark the FN history as deleted
    list<String> ActivityIds = new List<String> ();
    for (OUC_Activity__c a : Trigger.old)
    ActivityIds.add(a.Id);

    ServiceRequestHistoryHelper.updateOUCActivityHistoryAsDeleted(ActivityIds);
    // when delete no other processing needed
    return;
  }
  /*
   * This trigger sets Activity Due Date  Bussiness Resolution date based on createdDate ,sla and Standard Bussines Hours values as inputs
   * Created date: 2015-01-25 
   */
  /*Disable Trigger for Data loads*/
  list<OUC_Activity__c> acts = new list<OUC_Activity__c> ();
  for (OUC_Activity__c a : trigger.new) {
    string legacyid = a.LegacyId__c == null ? '' : a.LegacyId__c;
    // Skip processing for legacy data inserts
    if (!(trigger.isinsert && legacyid.startswithignorecase('CSR-'))) {
      acts.add(a);
    }

    /* if (a.Contact_Name__c == null) {
      Contact con = [Select Id From Contact Where Email = :a.Contact_Email__c LIMIT 1];
     
      if (con != null) {
      a.Contact_Name__c = con.Id;
      }
      } */

    /*if (a.Contact_Name__c == null) {
      Case myCase = [select CaseNumber, contactId, Contact.email from case where Id = :a.Case__c LIMIT 1];
      if (myCase.contactId != null) {
        a.Contact_Name__c = myCase.contactId;
      }
    }*/
  }

  try {
    // pending refactoring time - methods leveraging standard business hours SLA logic used in case are stored in  ServiceRequestsHelper
    ServiceRequestsHelper.setSRActivityDueDate(acts, trigger.isInsert);
  }
  catch(exception e) {
    system.debug('unable to complete set bussinessDate--' + e);
  }

  /*Disable Trigger for Data loads*/


  /***************************************************************************************************************
    /   Legacy Code below - not known applicable as of DEC-14
    /
    /***************************************************************************************************************/
  /*
    * This trigger verifies Task Code Text, if its not empty it fetches the related data from Activity type object
    * Created by Swetha Sathya
    * Created date: 06-10-2014 
  */
  /***** 2014-12-16 Trigger functionality superseded by formulas to combine UI Task Code versus Open311 Task code & related values
    /////      ALSO - DEFAULT Activity Type deleted so throwing error

    list<String> taskCode = new list<String>();
    Set<Id> taskcodeSet = new Set<Id>();
   
    for(OUC_Activity__c o:trigger.new){
    if((o.Task_Code__c != null && o.Task_Code__c!='') && (o.Activity_Type__c==null)){
    taskCode.add(o.Task_Code__c.trim());
    }
    if((o.Task_Code__c == null || o.Task_Code__c=='') && (o.Activity_Type__c!=null)){
    taskcodeSet.add(o.Activity_Type__c);
    }
    }
   
    Map<String,Id> activityMap = new Map<String,Id>();
    Map<Id,String> taskcodeMap = new Map<Id,String>();
   
    for(Activity_Type__c  obj:[SELECT Id,Name FROM Activity_Type__c WHERE Name='DEFAULT'])
    activityMap.put(obj.Name,obj.Id);
   
    for(Activity_Type__c  obj:[SELECT Id,Name FROM Activity_Type__c WHERE Name IN:taskCode])
    activityMap.put(obj.Name,obj.Id);
   
    for(Activity_Type__c  obj:[SELECT Id,Name FROM Activity_Type__c WHERE Id IN:taskcodeSet])
    taskcodeMap .put(obj.Id,obj.Name);
   
    system.debug('----activityMap----------'+activityMap);
    system.debug('----taskcodeMap ----------'+taskcodeMap );
    for(OUC_Activity__c o:trigger.new){
    if((o.Task_Code__c != null && o.Task_Code__c!='') && (o.Activity_Type__c==null)){
    if(activityMap!=null && activityMap.size()>0){
    if(activityMap.KeySet().contains(o.Task_Code__c.trim()))
    o.Activity_Type__c = activityMap.get(o.Task_Code__c.trim());
    else
    o.Activity_Type__c = activityMap.get('DEFAULT');
    }
    }
    if((o.Task_Code__c == null || o.Task_Code__c!='') && (o.Activity_Type__c!=null)){
    if(taskcodeMap !=null && taskcodeMap.size()>0){
    if(taskcodeMap.KeySet().contains(o.Activity_Type__c))
    o.Task_Code__c= taskcodeMap.get(o.Activity_Type__c);
    else
    o.Task_Code__c= taskcodeMap.get('DEFAULT');
    }
    }
    }
    *******/

}