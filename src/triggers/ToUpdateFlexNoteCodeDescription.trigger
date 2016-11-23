trigger ToUpdateFlexNoteCodeDescription on FlexNote__c (before insert, before update, before delete) {

    if(Trigger.isDelete){
        
        //here we need to collect the servicer request history helper to mark the FN history as deleted
        list<String> FlexNoteIds =new List<String>();
        for(FlexNote__c fn:Trigger.old) 
            FlexNoteIds.add(fn.Id);
            
        ServiceRequestHistoryHelper.updateFlexNoteHistoryAsDeleted(FlexNoteIds);
        // when delete no other processing needed
        return;
    }
    
    list <String> fqIds = new list <String>();
    list<FlexNote__c>fn=new list<FlexNote__c>();
    list<FlexNote__c>legacyfn=new list<FlexNote__c>();
    
    for (FlexNote__c a:trigger.new){
        fqIds.add(a.FlexNote_Question__c);
  
        string legacyid = a.LegacyId__c==null?'':a.LegacyId__c;
        // Segregate legacy data inserts for separate processing        -- trigger.isinsert && 
        if( legacyid.startswithignorecase('CSR-') ){
            legacyfn.add(a);
        } else {
            fn.add(a);
        }
    }
    list <FlexNoteQuestion__c> fnQList =[select id,name,AnswerValues__c ,QuestionAlias__c,Answer_Type__c,Questions__c,Required__c from FlexNoteQuestion__c where id in:fqIds];
    // comment 3010
    /*Map<Id, String> decodeStr = new Map<Id, String>();
    decodeStr =ServiceRequestsHelper.getQuestionCodeAnswerMap(fnList);
    
    for(FlexNote__c oAnswer : trigger.new){
       //oAnswer.CodeDescription__c=decodeStr.get(oAnswer.FlexNote_Question__c);
   
    }*/
   // added 3010
    ServiceRequestsHelper.startFlexNoteProcess(fn,fnQList);
    
    LegacyLoadHelper.setLegacyFNCodeDescriptione(legacyfn, trigger.isinsert);
}