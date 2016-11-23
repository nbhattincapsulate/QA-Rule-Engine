public with sharing class WorkflowActionHelper {
        
        private static String concatop='&';
        public static Map<String,Map<String,List<WorkflowRuleAction__c>>> userIdMailContentMap = new Map<String,Map<String,List<WorkflowRuleAction__c>>>();
         
        public static void configureUpdateFieldAction(WorkflowRuleAction__c action){
            
             //for the main object if the relation ship is not defined take the rule object
             String key = action.Child_Relationship_Name__c!=null ? action.Child_Relationship_Name__c.toLowerCase() : action.Action_Object__c.toLowerCase(); 
             
             Set<String> fieldToAdd = WorkflowRuleEvaluation.criteriaFields.get(key)!=null ? WorkflowRuleEvaluation.criteriaFields.get(key): new Set<String>();  
             
             String field = action.Field_Name__c=='CrossObject' ? action.CrossObjectField__c.substringBetween('{!','}').toLowerCase(): action.Field_Name__c.toLowerCase();
             
             //now add the field :-
             if(!fieldToAdd.contains(field) && !field.startsWithIgnoreCase('What'))
                fieldToAdd.add(field);
                
             //get the merge fields from the value in case there are any?
             String value = getValueForUpdateAction(action);
             
             List<String> fieldList = WorkflowMergeFormulaHelper.getTheMergeFields(value);
             
             if(fieldList!=null){
                    for(String fld:fieldList){
                        if(!fieldToAdd.contains(fld.toLowerCase()))
                            fieldToAdd.add(fld.toLowerCase());
                     }
             }
                
             WorkflowRuleEvaluation.criteriaFields.put(key,fieldToAdd);
                    
                  
        }
        
        public static String getValueForUpdateAction(WorkflowRuleAction__c action){
            /**
              * For Long Text Area
              */
              String value=null;
              if(action.Field_Type__c == 'REFERENCE' && action.Reference_Id__c != null && action.Reference_Id__c != ''){
                  value = action.Reference_Id__c;
              }
              else if(action.Value__c == null && action.Long_Value__c != null){
                  value = action.Long_Value__c;
              }
              else{
                  value = action.value__c;
              }
              
              return value ;
        } 
        
     
        public static void configureSendEmailAction(WorkflowRuleAction__c action){
           Set<String> fieldToAdd = WorkflowRuleEvaluation.criteriaFields.get(action.Action_Object__c.toLowerCase())!=null ? WorkflowRuleEvaluation.criteriaFields.get(action.Action_Object__c.toLowerCase()): new Set<String>(); 
                
           if(action.Additional_Emails__c!=null){
                List<String> emails = action.Additional_Emails__c!=null? action.Additional_Emails__c.split(','):new List<String>();
                for(String email : emails){
                    List<String> fieldList = WorkflowMergeFormulaHelper.getTheMergeFields(email);
                              
                    if(fieldList!=null){
                         for(String fld : fieldList)
                                if(!fieldToAdd.contains(fld.toLowerCase()))
                                    fieldToAdd.add(fld.toLowerCase());
                    }
                    
                }
            }
             //finally add the fields back
            WorkflowRuleEvaluation.criteriaFields.put(action.Action_Object__c.toLowerCase(),fieldToAdd);  
        }
        
        
        
        public static void configureInsertRelatedObjectAction(WorkflowRule__c rule,WorkflowRuleAction__c action){
              
              if(!WorkflowRuleEvaluation.insertedRelatedRecordInfo.containsKey(action.Id))
                return;
              
              Set<String> fieldToAdd = WorkflowRuleEvaluation.criteriaFields.get(rule.Object_Name__c.toLowerCase())!=null ? 
                                             WorkflowRuleEvaluation.criteriaFields.get(rule.Object_Name__c.toLowerCase()): new Set<String>();
              
              for(WorkflowValues_for_Insert_Record__c info: WorkflowRuleEvaluation.insertedRelatedRecordInfo.get(action.Id).Values_for_Action_Insert_Record__r){
                    
                    List<String> fieldList = WorkflowMergeFormulaHelper.getTheMergeFields(info.Value__c);
                    if(fieldList!=null){
                         for(String fld : fieldList)
                                if(!fieldToAdd.contains(fld.toLowerCase()))
                                    fieldToAdd.add(fld.toLowerCase());
                    }
                    
                      
              } 
              //finally add the fields back
              WorkflowRuleEvaluation.criteriaFields.put(rule.Object_Name__c.toLowerCase(),fieldToAdd);
               
        }
        
        
        public static Map<String,Map<String,List<WorkflowRuleAction__c>>> buildListForEmail(Map<String,Map<String,List<WorkflowRuleAction__c>>> usersInSendEmailAction,String referenceId,WorkflowRuleAction__c a,String objId){
            if(!usersInSendEmailAction.containsKey(referenceId)){
                //if no                       
                List<WorkflowRuleAction__c> temp = new List<WorkflowRuleAction__c>{a};
                Map<String ,List<WorkflowRuleAction__c>> objTemp=  new Map<String ,List<WorkflowRuleAction__c>>();
                objTemp.put(objId,temp);
                usersInSendEmailAction.put(referenceId,objTemp);
            }
            else{
                Map<String ,List<WorkflowRuleAction__c>> objTemp = usersInSendEmailAction.get(referenceId);
                if(!objTemp.containsKey(objId))
                    objTemp.put(objId,new List<WorkflowRuleAction__c>{a});
                else
    
                    objTemp.get(objId).add(a);
                    
                usersInSendEmailAction.put(referenceId,objTemp);
            }
            return usersInSendEmailAction;
        }
        
        
        
        /**
        * method that will initialize valid action fields so that we can add it
        * in field list that will be queried
        */
        public static void initFieldInvolvedInActions(List<WorkflowRule__c> rules ,String sobjectName){
           
            /*
              Here also set up the relationship fields
            */
            Map<String, Schema.SObjectType> mapObj = Schema.getGlobalDescribe();
            
            Schema.DescribeSObjectResult R =mapObj.get(sobjectName).getDescribe();
                                      
            /**
            * the objects that are defined in the criteria a valid child relation ships
            */
            for(Schema.ChildRelationship child: R.getChildRelationships()){               
                Schema.DescribeSObjectResult descRes = child.getChildSObject().getDescribe();
                String objname =descRes.getName().toLowerCase();                               
                WorkflowRuleEvaluation.childParentRelationshipField.put(objname,child.getField().getDescribe().getName());                
            }
           
            //add this rule fields also to criteria field set as they need to be updated
            for(WorkflowRule__c rule : rules){
                for(WorkflowRuleAction__c action : rule.Workflow_Rule_Actions__r){
                    if(action.ActionType__c=='Update Field'){
                        WorkflowActionHelper.configureUpdateFieldAction(action);                     
                    }//end  action.Type__c=='Update Field'
                    else if(action.ActionType__c=='Send Email'){
                        WorkflowActionHelper.configureSendEmailAction(action);                     
                    }
                    else if(action.ActionType__c == 'Insert Related Object' ){                        
                        WorkflowActionHelper.configureInsertRelatedObjectAction(rule,action);
                    }// end action.Type__c == 'Insert Related Object'
                   
                }//end action
            }//end rule
            
        }//end method
        
    /* update a field - helper */
    public static Sobject updateField(WorkflowRuleAction__c action,String fieldname ,String value,SObject toUpdate){
        String objName = String.valueof(toUpdate.getSObjectType()).toLowerCase();
        
        Map<String,Schema.SObjectField> fieldList= WorkflowRuleUtils.getSchemaMap(objName).get(objName);
        system.debug(fieldList);
        system.debug(fieldname);
        Schema.Sobjectfield field = fieldList.get(fieldname.tolowerCase()); 
        Schema.Describefieldresult fieldDesc = field.getDescribe();
        String fldType = fieldDesc.getType().name();       
        if(value!=null)value = value.replaceAll('\'','');

        
        if(fldType.equalsIgnoreCase('reference')){
            try{
               
                Id referenceId;
                if(value!=null)referenceId = Id.valueof(value);
                if(referenceId.getSObjectType() == User.SobjectType && action.notify_User__c){
                      //String mailBody = 'You are assigned as '+ fieldDesc.getLabel() + ' for '+objectLabels.get(obj) +' <a href="'+sfURL+'/'+toUpdate.Id+'">Record</a>';
                    if(!userIdMailContentMap.containsKey(referenceId)){
                        //if no                       
                        List<WorkflowRuleAction__c> temp = new List<WorkflowRuleAction__c>{action};
                        Map<String ,List<WorkflowRuleAction__c>> objTemp=  new Map<String ,List<WorkflowRuleAction__c>>();
                        objTemp.put((String)toUpdate.get('id'),temp);
                        userIdMailContentMap.put(referenceId,objTemp); 
                    }
                    else{
                        Map<String ,List<WorkflowRuleAction__c>> objTemp = userIdMailContentMap.get(referenceId);
                        if(!objTemp.containsKey(toUpdate.Id))
                            objTemp.put(toUpdate.Id,new List<WorkflowRuleAction__c>{action});
                        else
                            objTemp.get(toUpdate.Id).add(action);
                            
                        userIdMailContentMap.put(referenceId,objTemp);
                    }
                }
            }
            catch(Exception ex){
                throw ex;
            }
            toUpdate.put(fieldname,value);
            /**
            * End 
            */
        }else if(fldType.equalsIgnoreCase('string') || fldType.equalsIgnoreCase('picklist')|| fldType.equalsIgnoreCase('email') || fldType.equalsIgnoreCase('url')|| fldType.equalsIgnoreCase('multipicklist')|| fldType.equalsIgnoreCase('phone')){       
            toUpdate.put(fieldname,value);
        }else if(fldType.equalsIgnoreCase('boolean')){   
            toUpdate.put(fieldname,Boolean.valueOf(value));
        }else if(fldType.equalsIgnoreCase('double') || fldType.equalsIgnoreCase('currency')|| fldType.equalsIgnoreCase('percent')){   
            toUpdate.put(fieldname,Decimal.valueOf(value));
        }else if(fldType.equalsIgnoreCase('integer')|| fldType.equalsIgnoreCase('number')){   
            toUpdate.put(fieldname,Integer.valueOf(value));
        }else  if(fldType.equalsIgnoreCase('date')){   
            toUpdate.put(fieldname,Date.valueOf(value));
        }else  if(fldType.equalsIgnoreCase('datetime')){  
            toUpdate.put(fieldname,DateTime.valueOfGmt(value));
        }  
        else if(fldType.equalsIgnoreCase('base64') && value != null){   
            toUpdate.put(fieldname,Blob.valueof(value));
        }
        else{
           
            toUpdate.put(fieldname,value);
        }                 
        return toUpdate;
    } 
    
     
    public static SObject applyInsertChildActions(WorkflowRuleAction__c action,SObject sobj,Sobject parent){  
      
        
        if(action.ActionType__c == 'Insert Related Object' ){
            if(WorkflowRuleEvaluation.insertedRelatedRecordInfo.containsKey(action.Id)){
                for(WorkflowValues_for_Insert_Record__c info: WorkflowRuleEvaluation.insertedRelatedRecordInfo.get(action.Id).Values_for_Action_Insert_Record__r){
                    
                   
                    String toupdatevalue= info.Reference_Id__c!=null? info.Reference_Id__c : info.Value__c;                  
                    //adding merge field logic here
                     if(toupdatevalue!=null && (toupdatevalue.contains('&') ||  toupdatevalue.startsWith('{!'))){
                            String valuetosave=WorkflowMergeFormulaHelper.doMerge(toupdatevalue,parent);                           
                            if(valuetosave != null && valuetosave != ''){ 
                                sobj = updateField(action,info.Name.tolowercase(),valuetosave,sobj);
                            }
                            //End
                    }                   
                    else{
                        sobj = updateField(action,info.Name.tolowercase(),toupdatevalue,sobj);
                    }
                }
            }
        }  
        return sobj;
          
       
    }
        
}