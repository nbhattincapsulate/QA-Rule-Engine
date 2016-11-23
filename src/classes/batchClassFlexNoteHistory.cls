global class batchClassFlexNoteHistory implements Database.Batchable<sObject> {

global batchClassFlexNoteHistory (){}
    
    public string AlternateQuery;
    
    public void SetAlternateQuery(string altquery){
    	AlternateQuery = altquery;
    }
    public Database.QueryLocator start(Database.BatchableContext context){  
        //string DefaultQuery = 'SELECT id,CodeDescriptionSourcePart1__c,CodeDescriptionSourcePart2__c,CodeDescription__c,CodeDescriptionSourcePart3__c,Flex_Note_Id__c FROM Flex_Note_History__c ';  
        string DefaultQuery = 'SELECT id,CodeDescriptionSourcePart1__c,CodeDescriptionSourcePart2__c,CodeDescription__c,Flex_Note_Id__c FROM Flex_Note_History__c ';  
        DefaultQuery += ' WHERE Flex_Note_Id__c LIKE \'CSR-%\'';
        //DefaultQuery += ' AND LastModifiedDate < 2014-12-10T00:00:00Z';
        if(test.isRunningTest()){
            DefaultQuery += ' LIMIT 200';
        } else {
        	//query += ' LIMIT 1000'; 
        }
        
        return Database.getQueryLocator(AlternateQuery!=null?AlternateQuery:DefaultQuery);
    }
    
   //Method to create Json format
   private string CreateJsonFormat(string Jname,string Jvalue,boolean performSplit){
            JSONGenerator gen=JSON.createGenerator(true);
            string result;
            if(performSplit){
            	list<string>codes= Jname.split(',');
            	list<string>values= Jvalue.split(',');
            	map<string,string> jmap = new map<string,string>();
            	for(integer i=0; i<codes.size(); i++){
            		if(codes[i].trim()!='') jmap.put(codes[i],values[i]);
            	}
            	result = JSON.serialize(jMap);
            } else {
            	gen.writeStartObject(); //It is used for making starting object(‘{‘)
	            gen.writeStringField(Jname,Jvalue);//Here it is used for making name ,value pair
             	gen.writeEndObject();//It is used for making end of object(‘}’)
             	result=gen.getAsString();          
            }

            System.debug('result:'+result);
            return result; 
   } 
     
   global void execute(Database.BatchableContext BC, LIST<Flex_Note_History__c> cas){
        //system.debug('cas--->'+cas);
        LIST<Flex_Note_History__c> upsertionlist=new LIST<Flex_Note_History__c>();
        string JsonName,JasonValue; 
        boolean doSplit ;
        
        for(Flex_Note_History__c f:cas)
        {        
            if(f.CodeDescriptionSourcePart1__c==null && f.CodeDescriptionSourcePart2__c==null){
                //continue;
                // using last update flag to work through rows
            } else {
	            JsonName=f.CodeDescriptionSourcePart1__c;
	            JasonValue=f.CodeDescriptionSourcePart2__c;
	            
	            //Enters only if CodeDescriptionSourcePart1__c is having value
	            if(f.CodeDescriptionSourcePart1__c!=null && f.CodeDescriptionSourcePart2__c==null){
	                JasonValue=f.CodeDescriptionSourcePart1__c;
	            } 
	            
	            //Enters only if CodeDescriptionSourcePart2__c is having value  
	            if(f.CodeDescriptionSourcePart2__c!=null && f.CodeDescriptionSourcePart1__c==null){
	                JsonName=f.CodeDescriptionSourcePart2__c;
	            }
	            
	            doSplit=false;
	
	            if(		f.CodeDescriptionSourcePart1__c != null 
	                &&	f.CodeDescriptionSourcePart2__c != null  	// data quality not so hot...
	            	&& 	f.CodeDescriptionSourcePart1__c != f.CodeDescriptionSourcePart2__c  ) {
	            		// might be split worthy - qualifies to test for end comma stripping
	            		//system.debug('ID: '+f.Flex_Note_Id__c + ' - ' + f.CodeDescriptionSourcePart1__c + ', ' + f.CodeDescriptionSourcePart2__c);
	            		if(	! String.IsBlank(f.CodeDescriptionSourcePart1__c.substringafter(',').trim()) ) {
			            	// validates there is a comma and there is valid/some text after the comma 
			            	doSplit = true;
	            		} else 	if(String.IsBlank(f.CodeDescriptionSourcePart1__c.substringafter(',').trim()) && String.IsBlank(f.CodeDescriptionSourcePart2__c.substringafter(',').trim()) ) {
	            			// both values have comma at end, and we don't have to split it, so strip those
	            			JsonName = JsonName.substringbeforelast(',');
	            			JasonValue = JasonValue.substringbeforelast(',');
	            		}

	            } 

	            string JFormatvalue=CreateJsonFormat(JsonName,JasonValue,doSplit);
	            f.CodeDescription__c=JFormatvalue;
	            // use sourcepart3 for testing
	            //f.CodeDescriptionSourcePart3__c=JFormatvalue;
            }
            upsertionlist.add(f);                                               
        }               
        
        try{
            //system.debug('upsertionlist--->'+upsertionlist);
            update upsertionlist;
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            throw e;       
        }
   }   

   global void finish(Database.BatchableContext BC) {
           
    }
}