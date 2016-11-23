@isTest 
private class scheduledBatchEventCreateTest {
static testMethod void scheduledBatchEventCreateTest() { 
    Test.StartTest();
    scheduledBatchEventCreate shb = new scheduledBatchEventCreate();
    String sch = '0 0 23 * * ?'; 
    String jobId = system.schedule('Test scheduled Batch Event', sch, shb); 
    CronTrigger ct = [SELECT Id, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
    System.assertEquals(0, ct.TimesTriggered);
    System.debug('Next fire time: ' + ct.NextFireTime); 
    Test.stopTest(); 
    } 
}