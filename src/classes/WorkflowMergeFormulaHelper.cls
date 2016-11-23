public with sharing class WorkflowMergeFormulaHelper {

	
	public static List<String> getTheMergeFields(String field){              
            if(field!=null && (field.contains('&') || field.startsWith('{!'))){
                List<String> splitVaue = field.split('&');
                List<String>  mergeFields = new List<STring>();
                for(String s:splitVaue){
                    s=s.trim();
                    if(s.startsWith('{!')){
                        String mergeField= s.substringBetween('{!','}');
                        mergeFields.add( mergeField.toLowerCase());
                    }
                }
                return mergeFields;
            }             
            return null;
    }
    
    public static String doMerge(String value,SObject o){
        
        value=value.replaceAll('\'','');
        List<String> splitVaue = value.split('&');
        for(String s:splitVaue){
            s=s.trim();          

            if(s.startsWith('{!')){
                String mergeField= s.substringBetween('{!','}');
                List<String> reference = mergeField.split('\\.');                    
                SObject fetchedChild ;
                              
                String fieldToFetch = reference[reference.size()-1];
                for(Integer i=0;i<reference.size()-1;i++){
                    if(reference[i]=='.' || reference[i].trim()=='' ) continue;
                    
                     //second condition :- @any point the reference returns null we cannot evaluate further
                    if(i>=1 && fetchedChild ==null) break;
                    
                     fetchedChild = fetchedChild==null ?  o.getSObject(reference[i]):fetchedChild.getSObject(reference[i]);              
                }
                
                //we need to update this line for multiple reference :it will throw an error fetched child is null
                String replacewithval =  fetchedChild==null ? '':string.valueof(fetchedChild.get(fieldToFetch)) ;               
                if(fetchedChild==null && !s.contains('.')) replacewithval = string.valueof(o.get(fieldToFetch));
                
                replacewithval = replacewithval ==null ? '':replacewithval ;
                value=value.replace(s,replacewithval);       
            }
        }
        value=value.replaceAll('&',' ');
   
        return value;
        
    }  
    
    //helper method that will fetch the value resolvinf merge fields
    public static String resolveValueFetched(WorkflowRuleAction__c action,String value,SObject o){

        if(value.contains('&') || value.startsWith('{!')){
                value=WorkflowMergeFormulaHelper.doMerge(value,o);
                             
        }       
        else{
            Map<String,Schema.SObjectField> fieldList = WorkflowRuleUtils.getSchemaMap(action.Action_Object__c.toLowerCase()).get(action.Action_Object__c.toLowerCase());
            String valueToUpdate =value;
            if(fieldList!=null && (fieldList.containsKey(value)==true ||  fieldList.containsKey(value.toLowerCase())==true)){
                 value = string.valueof(o.get(valueToUpdate));
            }                         
         }//end else
         
         return value;
         
    }


}