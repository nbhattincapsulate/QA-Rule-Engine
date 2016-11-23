/**
 * BulkScheduleTrigger
 * 
 * This trigger will look for Open Day updates and shift all following collections to the next applicable date.
 * @author Darkis
 */

trigger BulkScheduleTrigger on BulkSchedule__c (after update) {
    
    if (Trigger.isUpdate) {
        BulkSchedule__c oldRecord;
        BulkSchedule__c newRecord;
        // Get the old record.
        for (BulkSchedule__c bsOld : Trigger.old) {
          oldRecord = bsOld;
        }
        // Get the new record.
        for (BulkSchedule__c bs : Trigger.new) {
          newRecord = bs;
        }
        // If the update is to an Open Day then proceed.
        if (newRecord.Ward__c.equalsIgnoreCase('Open Day')) {
          System.debug('-----> [BulkScheduleTrigger] New Open Day request.');
          Date dateAfterOpenDay = null;
          BulkSchedule__c recordToDelete;
            
          try {
            // Get all the Bulk Schedules after this record based on date.  
            List<BulkSchedule__c> nextSchedules = [Select Id, Ward__c, ScheduleDate__c, Name From BulkSchedule__c Where ScheduleDate__c > :newRecord.ScheduleDate__c ORDER BY ScheduleDate__c ASC];
            System.debug('-----> [BulkScheduleTrigger] nextSchedules.size(): ' + nextSchedules.size());
            
            for(Integer i = 1; i < nextSchedules.size(); i++) {
              // If the current and previous row's ward's contain the word 'Ward' then switch the dates.
              if (nextSchedules[i].Ward__c.contains('Ward') && nextSchedules[i-1].Ward__c.contains('Ward')) {
                if (dateAfterOpenDay == null) {
                  dateAfterOpenDay = nextSchedules[i-1].ScheduleDate__c;      
                }
                nextSchedules[i-1].ScheduleDate__c = nextSchedules[i].ScheduleDate__c;
                // If the current row DOESN'T contain 'Ward' and the previous row DOES contain 'Ward'.
              } else if (!nextSchedules[i].Ward__c.contains('Ward') && nextSchedules[i-1].Ward__c.contains('Ward')) {
                if (dateAfterOpenDay == null) {
                  dateAfterOpenDay = nextSchedules[i-1].ScheduleDate__c;      
                }
                Integer counter = 1;
                // Continue looping through the results until we come accross a record that isn't a holiday/stop day.
                for (Integer z = i; z < nextSchedules.size(); z++) {
                  // If the next element has a ward then take it's date. If not then increment and continue.
                  if (nextSchedules[z+counter].Ward__c.contains('Ward')) {
                    break;
                  }    
                  counter++;
                }
                // Switch the previous rows date with the row after the Holiday/Open Day/Bulk Off Day.
                nextSchedules[i-1].ScheduleDate__c = nextSchedules[i+counter].ScheduleDate__c;
              } else {
                System.debug('-----> [BulkScheduleTrigger] SKIPPING --- Previous Row is Skippable: Ward__c => ' + nextSchedules[i-1].Ward__c + ', ScheduleDate__c => ' + nextSchedules[i-1].ScheduleDate__c);
              }
            }
              
            // Delete the last index from the list as it will no longer be needed.
            System.debug('-----> [BulkScheduleTrigger] Deleting previous last BulkSchedule...');
            recordToDelete = nextSchedules[nextSchedules.size() - 1];
              
            // Insert new record for Open Day at original choosen date. 
            BulkSchedule__c openDay = new BulkSchedule__c(
              ScheduleDate__c = oldRecord.ScheduleDate__c,
              Ward__c = 'Open Day'
            );
            nextSchedules.add(openDay);
            // Modify the old record to have the new date and add it to the list. 
            BulkSchedule__c originalRecord = [Select Id, ScheduleDate__c, Ward__c From BulkSchedule__c Where Id = :newRecord.Id];
            originalRecord.ScheduleDate__c = dateAfterOpenDay;
            originalRecord.Ward__c = oldRecord.Ward__c;
            nextSchedules.add(originalRecord);
            
            // Upsert all the existing records and new open day record. 
            upsert nextSchedules; 
            // Delete the last duplicate record.
            delete recordToDelete;
          } catch (Exception e) {
            System.debug('-----> [BulkScheduleTrigger] Error: ' + e.getMessage());
          }
        }
    }
}