/*	This used for scheduling snowattribute batch
   *	
   *
   */ 
	global class ScheduleSnowAttributeBatch implements Schedulable {

		// Schedule Class for daily Sync 
		global void execute(SchedulableContext SC) {
			//SnowAttributesFetchBatch sAFB =  new SnowAttributesFetchBatch();
			system.abortJob(sc.getTriggerId());
			Database.executeBatch(new SnowAttributesFetchBatch(),200); 
		}

	}