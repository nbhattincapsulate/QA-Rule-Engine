@isTest(seealldata=true)
private class batchClassBulkCollectionTest {
     static testMethod void start() {
     
        batchClassBulkCollection  bc=new batchClassBulkCollection ();
        Database.BatchableContext BatchCont;
        
        contact con=new contact();
        con.lastname='jois';
        con.email='jois@gmail.com';
        insert con;                      
        
        OUCServiceRequestConfig__c OSR=[SELECT BulkCollectionScheduleQuestion__c FROM OUCServiceRequestConfig__c];
        string str=OSR.BulkCollectionScheduleQuestion__c;
        string ido;
        list<FlexNoteQuestion__c> FF=[SELECT id,Questions__c FROM FlexNoteQuestion__c ];
        for(integer i=0;i<FF.size();i++){
              if(FF[i].Questions__c.contains(str))
                  ido=FF[i].id;   
        }
        
        list<ServiceRequestType__c> SRT=[Select Id FROM ServiceRequestType__c WHERE Service_Name__c='Bulk Collection'];
               
        list<case> cas=new list<case>();
        case c=new case();
        c.ContactId=con.id;
        c.Ward__c='Ward 2';
        c.Origin='311-App';
        c.SRType__c=SRT[0].Id;           //'a06r000000048nzAAA';
        insert c;
        cas.add(c);              
        
        FlexNoteQuestion__c FNQ=new FlexNoteQuestion__c();
        FNQ.Questions__c='NEXT BULK SCHEDULE COLLECTION DATE';
        FNQ.Object_Name__c='case';
        FNQ.Name='E0710';
        FNQ.Answer_Type__c='text';
        insert FNQ;
        
        FlexNote__c FN=new FlexNote__c();
        //FN.Name='a02r0000000UyEi';
        FN.FlexNote_Question__c=ido;       //'a01r0000000Bu49AAC';
        FN.Case__c=c.id;
        FN.Answer__c='';
        insert FN;           
        
        SelfSchedule schedBatch= new SelfSchedule(); 
        String chron = '0 0 12 * * ?';        
        system.schedule('Test Sched', chron, schedBatch);     
        
        bc.start(BatchCont);
        bc.execute(BatchCont,cas);
        bc.finish(BatchCont);
    }
}