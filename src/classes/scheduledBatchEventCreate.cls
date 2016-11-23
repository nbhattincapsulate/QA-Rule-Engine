global class scheduledBatchEventCreate implements Schedulable { 
   global void execute(SchedulableContext sc) { 
      batchEventCreate b = new batchEventCreate(); 
      database.executebatch(b); 
   } 
}