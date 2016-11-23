global class batchClassBulkCollection implements Database.Batchable<sObject> {

global batchClassBulkCollection(){}
    
    public Database.QueryLocator start(Database.BatchableContext context){
        list<ServiceRequestType__c> SRT=[Select Id FROM ServiceRequestType__c WHERE Name='S0031']; 
        string str='311-App';             
        string str1=SRT[0].id;
        string str2='open';
        string query = 'SELECT Id,SRType__c,ContactId,Ward__c FROM case WHERE  Origin=:str AND SRType__c=:str1 AND Status=:str2';  
        return Database.getQueryLocator(query);
    }
   
   /*public Database.QueryLocator call(){
        list<Flex_Note_History__c> dd= [SELECT id,CodeDescriptionSourcePart1__c,CodeDescriptionSourcePart2__c,CodeDescriptionSourcePart3__c FROM Flex_Note_History__c ];          
        system.debug('-------dd---------'+dd); 
        return null; 
   }*/
   
   global void execute(Database.BatchableContext BC, LIST<case> cas)  {
   system.debug('-------cas---------'+cas);
         list<string> listofid=new list<string>();
         string FlexNoteQuestionCode;
         list<FlexNoteQuestion__c> FNC=[SELECT Name,Questions__c FROM FlexNoteQuestion__c];
         list<OUCServiceRequestConfig__c> OSRC=[SELECT BulkCollectionScheduleQuestion__c FROM OUCServiceRequestConfig__c];
         string flexnoteQuestion=OSRC[0].BulkCollectionScheduleQuestion__c; 
         for(FlexNoteQuestion__c f:FNC){
             if(f.Questions__c.contains(flexnoteQuestion)){
                 FlexNoteQuestionCode=f.name;    
             }
             
         }
         for(case c:cas)
             listofid.add(c.id);
             for(string l:listofid)
             system.debug('-------listofid---------'+l);
             system.debug('-------FlexNoteQuestionCode---------'+FlexNoteQuestionCode);
         //string str='DE0710'; //FlexNoteQuestionCode
         list<FlexNote__c > FlexNote= new list<FlexNote__c >([SELECT Id,Answer__c,Case__c,FlexNoteQuestionCode__c from FlexNote__c  WHERE Case__c in :listofid AND FlexNoteQuestionCode__c=:FlexNoteQuestionCode]);
         list<FlexNote__c > FNcopy= new list<FlexNote__c >();
         system.debug('-------FlexNote---------'+FlexNote);  
         for(FlexNote__c fn:FlexNote){  
             if(fn.Answer__c==null || fn.Answer__c==''){                 
                 FNcopy.add(fn);                                 
             }           
         }
         system.debug('-------FNcopy---------'+FNcopy);
         
         sObject  SRHInstanceValue;
         List<string> listofContactid=new list<string>();
         Map<id, FlexNote__c> mapofConactidFlexnote = new Map<id, FlexNote__c>();
         Map<id, contact> mapofConactidContactemail = new Map<id, contact>();
         Map<contact, FlexNote__c> mapofContactEmailFlexnote = new Map<contact, FlexNote__c>();
         list<FlexNote__c> listtoupsertFlexNote=new list<FlexNote__c>();
         
         for(case c:cas)
         for(FlexNote__c fc:FNcopy)
         {
             if(fc.Case__c == c.Id && c.Ward__c!=null){                   
                     listofContactid.add(c.ContactId);
                     mapofConactidFlexnote .put(c.ContactId,fc); 
                     system.debug('cas--->'+cas);
                     system.debug('c.Ward__c---->'+c.Ward__c);
                         SRHInstanceValue=ServiceRequestsHelper.getFlexNoteDefault(c.Ward__c ,'DailyLimit'); 
                     System.debug('SRHInstanceValue-->'+SRHInstanceValue); 
                     if(SRHInstanceValue!=null){
                         System.debug('SRHInstanceValue-->'+SRHInstanceValue);
                         string strdate=String.valueOf(SRHInstanceValue.get('ScheduleDate__c'));   
                         String delims = '-+';
                         String[] tokens = strdate.split(delims); 
                         string strdate2=tokens[2];
                         String delims2 = ' +'; 
                         String[] tokens2 = strdate2.split(delims2);        
                         fc.Answer__c=tokens[1]+'/'+tokens2[0]+'/'+tokens[0];
                         listtoupsertFlexNote.add(fc);
                     }
                 //upsert fc;                   
             }            
         }
         //try{
         System.debug('listtoupsertFlexNote--->'+listtoupsertFlexNote);
             upsert listtoupsertFlexNote;
         //}
        // catch(Exception e){
            // System.debug('An exception occurred: ' + e.getMessage());
            // throw e; 
        // }
         
         list<Contact> ContactEmail= new list<Contact>([SELECT Id,Email,Schedule_Date__c from Contact WHERE id in:listofContactid]);
         EmailTemplate EmailTemplateId=[SELECT Id from EmailTemplate WHERE Name='Scheduling Date for bulk collection'];
         System.debug('EmailTemplateId--->'+EmailTemplateId);
         list<contact> listofupsertcontact=new list<contact>();
         for(Contact con:ContactEmail){
             mapofConactidContactemail.put(con.Id,con);
         }
         
         for (Id id1 : mapofConactidFlexnote.keySet())
         for (Id id2 : mapofConactidContactemail.keySet())
         {
             if(id1==id2) //id1 and id2 are Contact ids
             {
               list<string> email=new list<string>();
               mapofContactEmailFlexnote.put(mapofConactidContactemail.get(id1),mapofConactidFlexnote.get(id2));
               
               mapofConactidContactemail.get(id1).Schedule_Date__c = mapofConactidFlexnote.get(id2).Answer__c; 
               //upsert mapofConactidContactemail.get(id1);
               listofupsertcontact.add(mapofConactidContactemail.get(id1));
             }
         }
         
         try{
             upsert listofupsertcontact;
         }
         catch(Exception e){
             System.debug('An exception occurred: ' + e.getMessage());
             throw e; 
         }
         
         for(contact con:listofupsertcontact){         	
             //Sending Email to case contact email
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               mail.setTargetObjectId(con.id);
               system.debug('--setTargetObjectId----'+mail);
               String[] toaddress = new String[]{con.email};
               mail.setToAddresses(toaddress);
               system.debug('--setToAddresses----'+mail);
               mail.setTemplateId(EmailTemplateId.id);
               
               if(!Test.isRunningTest()){
               		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
               }
               
               //call();
         }        
        
        
   }   

   global void finish(Database.BatchableContext BC) {       
       //calling another batch class
       /* removing execution of unrelated batch ER 2014-12-26
       batchClassFlexNoteHistory batchFNH=new batchClassFlexNoteHistory ();
       id dbi=database.executebatch(batchFNH,200);
       */
       
       //Scheduling the batch every 5 min
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(300);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        system.debug(chron_exp);
        
        System.schedule('acctBatch2Job' + sysTime.getTime(),chron_exp,new SelfSchedule());
    }
}