@isTest
public class BulkScheduleTriggerTest {
  public static testMethod void testBulkScheduleTrigger() {
      // TODO: Positive: 'Open Day' flow.
      // 
      // TODO: Negative: Normal Ward/Holiday change. 
    List<BulkSchedule__c> testSchedules = new List<BulkSchedule__c>{
      new BulkSchedule__c(
        ScheduleDate__c = Date.TODAY(),
        Ward__c = 'Ward 2, Ward 4'
      ),
      new BulkSchedule__c(
        ScheduleDate__c = Date.TODAY().addDays(1),
        Ward__c = 'Ward 3, Ward 7'
      ),
      new BulkSchedule__c(
        ScheduleDate__c = Date.TODAY().addDays(2),
        Ward__c = 'Ward 6, Ward 8'
      ),  
      new BulkSchedule__c(
        ScheduleDate__c = Date.TODAY().addDays(3),
        Ward__c = 'Ward 1, Ward 5'
      )   
    };  
    insert testSchedules;
    // Modifiy exisiting entry to trigger trigger.
    List<BulkSchedule__c> schedules = [Select Id, ScheduleDate__c, Ward__c From BulkSchedule__c ORDER BY ScheduleDate__c ASC];
	// Assert that we have 4 bulk schedules in the DB.
    System.assertEquals(4, schedules.size());    
    // Update one record to be open day.
    schedules[0].Ward__c = 'Open Day';
    update schedules[0];
    // Fetch updated results.
    schedules = [Select Id, ScheduleDate__c, Ward__c From BulkSchedule__c ORDER BY ScheduleDate__c ASC];  
    // Assert there are still only four meaning the last entry was deleted.  
    System.assertEquals(4,schedules.size());  
    // Loop through the original test subjects and the inserted ones comparing the dates. 
    for (Integer i = 0; i < schedules.size(); i++) {
	  // If this is the first index then just ensure it is 'Open Day' for the modified schedules.
      if (i == 0) {
        System.assertEquals('Open Day', schedules[i].Ward__c);    
      } else {
        System.assertEquals(testSchedules[i-1].ScheduleDate__c.addDays(1), schedules[i].ScheduleDate__c);  
      }
    }
    // Modify and save one of the schedules.
    schedules[0].Ward__c = 'Ward 1, Ward 5';
    update schedules;
    // Add more schedules for some holidays. 
    List<BulkSchedule__c> holidaySchedules = new List<BulkSchedule__c>{
      new BulkSchedule__c(
        ScheduleDate__c = Date.today().addDays(5),
        Ward__c = 'Boxing Day'
      ),
      new BulkSchedule__c(
        ScheduleDate__c = Date.today().addDays(6),
        Ward__c = 'Christmas Day'
      ),
      new BulkSchedule__c(
        ScheduleDate__c = Date.TODAY().addDays(7),
        Ward__c = 'Ward 6, Ward 8'
      ),  
      new BulkSchedule__c(
        ScheduleDate__c = Date.TODAY().addDays(8),
        Ward__c = 'Ward 1, Ward 5'
      )   
    }; 
    insert holidaySchedules;
    // Modify one entry for open day to test the holiday logic. 
    schedules[0].Ward__c = 'Open Day';
    update schedules;
      
  }
}