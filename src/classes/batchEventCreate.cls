global class batchEventCreate implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Query all Service Request related events which are expiring today
        String query = 'SELECT Id, EndDateTime, WhatID,StartDateTime,DurationInMinutes FROM event WHERE EndDateTime = LAST_N_DAYS:1 and What.Type= \'' + String.escapeSingleQuotes('Case') + '\'';
        return Database.getQueryLocator(query);        
    }   
    global void execute(Database.BatchableContext BC, List<event> expEventList) {        
        List<Id> tempCaseId = new List<Id>();
        List<Case> caseList = new List<Case>();
        DateTime expDate;              
        for(event e : expEventList) {
         //capture all Case Id's related to expiring events
         tempCaseId.add(e.WhatId);
         system.Debug('Inside Event e----> '+ e);                       
         }         
          caseList =[SELECT Id, Expected_Resolution_Date__c FROM Case WHERE Id In :tempCaseId];              
          Map <String, DateTime> caseMap = new map <String, DateTime>();
          system.Debug('Before Update----> ' + caseMap);           
          for(case c: caseList){
              if(c.id != NULL || c.id !=''){
              system.Debug('caseId'+ c.id + 'case List' + c);
              //map cases id and it's expected resolution date
              caseMap.put(c.Id, c.Expected_Resolution_Date__c);
               system.Debug('Inside caseList c---->'+ c);
               }
          } 
            for(event e1 : expEventList) {                  
             if( caseMap.containsKey(e1.WhatId)) { 
                 
                 if(DateTime.valueOf(caseMap.get(e1.WhatId))< system.now() + 14)
                     {      
                     system.Debug('if part----> ' + (system.now()+14));   
                     e1.DurationInMinutes = null;                                        
                     e1.EndDateTime =  DateTime.valueOf(caseMap.get(e1.WhatId));   
                     system.Debug('After Update----> ' + e1.EndDateTime);  
                     } 
                 else
                     {
                     system.Debug('else part----> ' + (system.now()+12) + 'TodayDate' + system.now() + 'Event End date' + e1.EndDateTime);
                     e1.DurationInMinutes = null;
                     e1.StartDateTime = system.now();                         
                     e1.EndDateTime =  system.now()+14;  
                     }         
             }
            update expEventList;
            system.Debug('Updated----> '+ expEventList);               
            }
    }      
    global void finish(Database.BatchableContext BC) {
    }
}