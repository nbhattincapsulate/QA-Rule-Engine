global class SelfSchedule implements schedulable  
{  
     
     global void execute(SchedulableContext sc)  
     { 
         system.abortJob(sc.getTriggerId()); 
         Database.executeBatch(new batchClassBulkCollection(),200);            
     }
     
}