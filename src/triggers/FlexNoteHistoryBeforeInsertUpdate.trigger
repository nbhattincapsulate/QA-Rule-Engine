trigger FlexNoteHistoryBeforeInsertUpdate on Flex_Note_History__c (before insert, before update) {
	// APPLIES TO LEGACY DATA LOAD only
	// -- Calls method to populate CodeDesription__c with JSON string 
	 
    list<Flex_Note_History__c>legacyfn=new list<Flex_Note_History__c>();
    
    for (Flex_Note_History__c a:trigger.new){
      	string legacyid = a.Flex_Note_Id__c==null?'':a.Flex_Note_Id__c;
        // Segregate legacy data inserts for separate processing		 
        if( legacyid.startswithignorecase('CSR-') ){
        	legacyfn.add(a);
        } 
    }
   	
   	LegacyLoadHelper.setLegacyFNCodeDescriptione(legacyfn, trigger.isinsert);
}