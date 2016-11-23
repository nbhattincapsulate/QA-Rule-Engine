public class LegacyLoadHelper {

	/*   Legacy Data Load Helper methods
	
	*/
	
	// 	setLegacyFNCodeDescription
	//		--- sets JSON string for FlexNote code description during legacy data load - additional fields are provided to construct this 
	//			since meta data from CSR not all configured within 311Force
	public static void setLegacyFNCodeDescriptione(list<FlexNote__c> tempFNList, boolean Trigger_IsInsert){

        string JsonName,JasonValue; 
        boolean doSplit ;
			
		for(FlexNote__c f : tempFNList){
            if(f.CodeDescriptionSourcePart1__c==null && f.CodeDescriptionSourcePart2__c==null){
                //continue;
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
			}// else
        }//for
	}

	//  SHOULD BE IDENTICAL to above method except using Flex_Note_History__c instead of FlexNote__c
	// 		-- no time to abstract core logic from object manipulation
	public static void setLegacyFNCodeDescriptione(list<Flex_Note_History__c> tempFNList, boolean Trigger_IsInsert){

        string JsonName,JasonValue; 
        boolean doSplit ;
			
		for(Flex_Note_History__c f : tempFNList){
            if(f.CodeDescriptionSourcePart1__c==null && f.CodeDescriptionSourcePart2__c==null){
                //continue;

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
			}// else
        }//for
	}
	
   private static string CreateJsonFormat(string Jname,string Jvalue,boolean performSplit){
            JSONGenerator gen=JSON.createGenerator(true);
            string result;
            if(performSplit){
            	list<string>codes= Jname.split(',');
            	list<string>values= Jvalue.split(',');
            	map<string,string> jmap = new map<string,string>();
            	integer minarraysize = codes.size()<=values.size()?codes.size():values.size();
            	for(integer i=0; i<minarraysize; i++){
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

}