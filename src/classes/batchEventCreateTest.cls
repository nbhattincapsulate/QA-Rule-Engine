@isTest 
private class  batchEventCreateTest { 
    static testmethod void testEventBatch() {  
    // Create test records                                         
        Case c = new Case(Subject ='Alley Repair',Address__c ='702 19TH STREET NE',FlexNotes__c ='test Batch');                
        insert c;                 
        Event e = new Event(Subject ='Other', StartDateTime= system.now(), EndDateTime=system.now(),  WhatId=c.Id);          
        insert e;            
        ServiceRequestType__c  st = new  ServiceRequestType__c();     
        st.Name         ='S0016';
        st.SLAType__c   ='Business days';
        st.SLA__c       = '270';
        //  st.SRType__c    = c.id;
        insert st;                    
        Test.startTest(); 
        batchEventCreate  b = new batchEventCreate(); 
        Database.executeBatch(b); 
        Test.stopTest();   
    } 
}