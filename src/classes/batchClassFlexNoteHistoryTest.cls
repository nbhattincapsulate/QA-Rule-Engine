@isTest(seealldata=true)
private class batchClassFlexNoteHistoryTest {
     static testMethod void start() {
         
         batchClassFlexNoteHistory bc=new batchClassFlexNoteHistory ();
         Database.BatchableContext BatchCont;
         //list<case> cas=[Select Id,origin FROM case WHERE origin='311-App' limit 10]; 
         Case c1=new Case(subject='testaroo');
         insert c1;
         Case c2=new Case(subject='testaroo');
         insert c2;
         Case c3=new Case(subject='testaroo');
         insert c3;
         Case c4=new Case(subject='testaroo');
         insert c4;
         
         Service_Request_History__c SRH=new Service_Request_History__c();
         SRH.CaseNumber__c=c1.id;
         insert SRH;
         
         Service_Request_History__c SRH1=new Service_Request_History__c();
         SRH1.CaseNumber__c=c2.id;
         insert SRH1;
         
         Service_Request_History__c SRH2=new Service_Request_History__c();
         SRH2.CaseNumber__c=c3.id;
         insert SRH2;
         
         Service_Request_History__c SRH3=new Service_Request_History__c();
         SRH3.CaseNumber__c=c4.id;
         insert SRH3;

         
         //list<FlexNoteQuestion> lsFNQ=[Select Id,name FROM FlexNoteQuestion WHERE Questions__c='SCHEDULED BULK COLLECTION DATE (cannot be changed)' limit 10];
         FlexNoteQuestion__c FNQ=new FlexNoteQuestion__c();
         FNQ.Questions__c='NEXT BULK SCHEDULE COLLECTION DATE';
         FNQ.Object_Name__c='case';
         FNQ.Name='aaaa';
         FNQ.Answer_Type__c='text';
         insert FNQ;
         
         list<Flex_Note_History__c> ls=new list<Flex_Note_History__c>();
         Flex_Note_History__c FNH=new Flex_Note_History__c();
         FNH.Name='xxxx';
         FNH.Service_Request_History__c=SRH.id;
         FNH.CodeDescriptionSourcePart1__c='FURNI001,HOUSAPP';
         FNH.CodeDescriptionSourcePart2__c='Furniture,Householdapplieances';
         insert FNH;
         ls.add(FNH);
         
         Flex_Note_History__c FNH1=new Flex_Note_History__c();
         FNH1.Name='yy';
         FNH1.Service_Request_History__c=SRH1.id;
         insert FNH1;
         ls.add(FNH1);
         
         Flex_Note_History__c FNH2=new Flex_Note_History__c();
         FNH2.Name='bb';
         FNH2.Service_Request_History__c=SRH2.id;
         FNH2.CodeDescriptionSourcePart1__c='gggg';
         insert FNH2;
         ls.add(FNH2);
         
         Flex_Note_History__c FNH3=new Flex_Note_History__c();
         FNH3.Name='bb';
         FNH3.Service_Request_History__c=SRH3.id;
         FNH3.CodeDescriptionSourcePart2__c='gggg';
         insert FNH3;
         ls.add(FNH3);         

         Flex_Note_History__c FNH4=new Flex_Note_History__c();
         FNH4.Name='awaaw';
         FNH4.Service_Request_History__c=SRH3.id;
         FNH4.CodeDescriptionSourcePart1__c='CODE1,';
         FNH4.CodeDescriptionSourcePart2__c='value1,';
         insert FNH4;
         ls.add(FNH4);         
         
         bc.start(BatchCont);
         bc.execute(BatchCont,ls);
         bc.finish(BatchCont);

         bc.SetAlternateQuery('invalid string');
     }    
}