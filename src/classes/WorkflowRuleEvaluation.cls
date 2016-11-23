public with sharing class WorkflowRuleEvaluation {
        
    
    //required to stop the trigger to start
    public static Boolean EvaluationIsRunning=false;
    
    
    //required for trigger chaining every trigger that calls this class will add it self to this set so
    //that the same sobject trigger does not start evaluation running
    public static Set<String> EvaluationRunningFor = new Set<String>();
    
    //stores the fields that needs to be quired
    public static Map<String,Set<String>> criteriaFields;  
     
    // Child object to be inserted
    public static List<SObject> childObjectList = new List<SObject>();
    
    // Map of Rule Action Id and Insert Related Record Info object as child 
    public static Map<Id,WorkflowRuleAction__c> insertedRelatedRecordInfo = new Map<Id,WorkflowRuleAction__c>();
    
    // Map of child relationship name and field in child for parent
    public static Map<String,String> childParentRelationshipField = new Map<string,String>();
    
    
    public static Map<Id,SObject> toUpdateSObject;      
    
    public static Boolean failTrigger = false;
        
    /** added this variable to hold the oldRecords in case of update **/
    public static  Map<Id,SObject> oldListMap = new Map<Id,SObject>();
    public static Boolean isUpdate=false;
         
         
   /**
    * this method starts the processing engine for evaluation the rules
    * params : 
    * recordIds : ids of the object records that needs to be evaluated 
    * sobjectName : object(Account,Contact)
    * action : update/insert      
    */
    public static void startWorkflow(Set<Id> recordIds,String sobjectName,Boolean isInsert){        
        System.debug('----> Start Workflow: Enter');
        // get the rules get all types of rules
        String query ='Select Id,Evaluation_Rule__c,Object_Name__c FROM WorkflowRule__c WHERE Object_Name__c=\''+sobjectName+'\' AND Active__c=true ';
        isUpdate = !isInsert;
        
        if(!isInsert){
            query+=' AND Evaluation_Rule__c!=\'Record is created\'';
        }
        
        //list of rules
        List<WorkflowRule__c> ruleList = database.query(query);
        if(ruleList.size()==0) return;
        
        Map<Id,WorkflowRule__c> rules = new Map<Id,WorkflowRule__c> (ruleList);
        evaluateWorkflowRules(rules.keySet(),recordIds,sobjectName);
        System.debug('----> Start Workflow: Exit');
    }
    
    
    /*
      this is where the entire execution process is started:-
      Get all the rules defined for this sobject
      & evalaute those rule against the records
    */
            
    public static Boolean evaluateWorkflowRules(Set<Id> ruleIds,Set<Id> recordIds,String sobjectName){ 
        	System.debug('----> Evaluate Workflow Rules: Enter');
            /*
              get the criteria,actions for the rules
            */
            List<WorkflowRule__c> rules = WorkflowRuleHelper.getWorkflowRuleDetails(ruleIds);
            
            /*
              Once we get the workflowRuleCriteria build the criteria fields to query
              so that we can only fetch the required fields
            */
            initFieldInvolvedInCriteria(rules,sobjectName); 
            //system.debug(criteriaFields);
            /*
              Once we get the workflowRuleActions build the action fields to query
              so that we can only fetch the required fields
            */
            WorkflowActionHelper.initFieldInvolvedInActions(rules,sobjectName);
            //system.debug(criteriaFields);
            
            //initialize the mapping records
            insertedRelatedRecordInfo = WorkflowRuleHelper.getInsertRelatedRecordInfo(ruleIds);
            
            //Set this flag on needed for recursive trigger calls
            EvaluationIsRunning=true;
            
            //now done let use fetch the records for executiong & evaluation
            Set<String> parentFields = criteriaFields.get(sobjectName.toLowerCase())==null?
                                       new Set<String>():criteriaFields.get(sobjectName.toLowerCase());
                                        
            
            List<String> lstFields = new List<String>();
            
            if(parentFields==null || parentFields.size()==0 || !parentFields.contains('id')) {
                parentFields.add('id');         
            }
            
            lstFields.addAll(parentFields);
            String fields = String.join(lstFields,',');

           
            String qrySOQL='';
           
            qrySOQL='SELECT  ' + fields +' ';
            
             //now add the child queries also as they need to be evaluated in the query :)
            for(String obj:criteriaFields.keySet()){
                if(obj.equalsIgnoreCase(sobjectName.toLowerCase())) continue;                 
                lstFields = new List<String>();    
                lstFields.addAll(criteriaFields.get(obj));     
                fields =String.join(lstFields,',');
                if(fields!= null && fields != ''){
                    qrySOQL+=' , (SELECT  ' + fields +',Id  FROM '+obj+')';
                }
            }
              
            qrySOQL+=' FROM '+sobjectName+' WHERE Id IN : recordIds';
            
            List<SObject> sobjectRecords = database.query(qrySOQL);  
            
            toUpdateSObject= new Map<Id,SObject>();
            childObjectList = new List<SObject>(); 
            
            Map<String,List<SObject>> toUpdateChildObjects = new Map<String,List<SObject>>();
             
            Map<String,Map<String,List<WorkflowRuleAction__c>>> usersInSendEmailAction =new Map<String,Map<String,List<WorkflowRuleAction__c>>> ();
            Map<String,Map<String,List<WorkflowRuleAction__c>>> grpsInSendEmailAction = new Map<String,Map<String,List<WorkflowRuleAction__c>>> ();
            
            
           //start the evaluation for each rule
            for(SObject so:sobjectRecords){
                
                for(WorkflowRule__c rule : rules){
                    System.debug('----------------------------WorkflowRule Start => '+ rule.Id +'/'+ rule.Name +'----------------------------');
                    Boolean isValid = evaluateRule(so,rule);
                    if(isValid){                    
                            //the rule has met all the conditions time for action :)
                            for(WorkflowRuleAction__c action : rule.Workflow_Rule_Actions__r){
                                	System.debug('----> WorkflowRuleAction__c => ActionType__c: ' + action.ActionType__c);
                                
                                    if(action.ActionType__c == 'Send Email'){
                                         Id sendTo = action.User_Owner_Id__c !=null ? Id.valueof(action.User_Owner_Id__c):UserInfo.getUserId();
                                         if(action.additional_emails__c!=null){
                                            action.additional_emails__c = WorkflowMergeFormulaHelper.doMerge(action.additional_emails__c.replaceAll(',','&'),so);
                                            action.additional_emails__c = action.additional_emails__c.replaceAll(' ',',');
                                         }
                                         
                                         if(sendTo.getSObjectType() == User.SobjectType ){                                                                           
                                            usersInSendEmailAction=WorkflowActionHelper.buildListForEmail(usersInSendEmailAction,sendTo,action,so.Id);
                                         }else if(sendTo.getSObjectType() == Group.SobjectType){                                            
                                            grpsInSendEmailAction=WorkflowActionHelper.buildListForEmail(grpsInSendEmailAction,sendTo,action,so.Id);
                                         } 
                                    }else if(action.ActionType__c=='Update Field'){
                                            applyUpdateAction(action,so);
                                    }
                                    else if(action.ActionType__c=='Insert Related Object'){
                                        String parentFieldName = childParentRelationshipField.get(action.Action_Object__c.tolowerCase());
                                         /**
                                        * Dynamically create child instance
                                        */
                                        Type t = Type.forName(action.Action_Object__c);
                                        SOBject newObj = (SObject)t.newInstance();  
                                        
                                         if(action.Action_Object__c.tolowerCase()=='task'){
                                            if(so.Id.getSObjectType() == User.SobjectType){
                                                parentFieldName='OwnerId';
                                            }else  if(so.Id.getSObjectType() == Contact.SobjectType || so.Id.getSObjectType() == Lead.SobjectType){
                                                parentFieldName='WhoId';
                                            }
                                            if(so.Id.getSObjectType() != Contact.SobjectType && so.Id.getSObjectType() != Lead.SobjectType){
                                                parentFieldName='WhatId';
                                            }
                                        }
                                      
                                         if (parentFieldName!= null ) newObj = WorkflowActionHelper.updateField(action,parentFieldName,so.Id,newObj);
                                         /**
                                          * Apply rest of the fields
                                          */
                                        
                                         newObj = WorkflowActionHelper.applyInsertChildActions(action,newObj,so);
                                        
                                         childObjectList.add(newObj);   
                                         system.debug('----> newObj: ' + newObj);
                                    }else if(action.actiontype__c=='Notification'){
                                        
                                        WorkflowNotification__c  notify= new WorkflowNotification__c(message__c=action.long_value__c);
                                        childObjectList.add(notify);  
                                        
                                    }else if(action.actiontype__c=='Error'){
                                        //error time
                                        throw new WorkflowException(action.long_value__c);
                                    }
                                
                                
                            }//end rule action
                        
                    }//end isvalid
                    System.debug('----------------------------WorkflowRule Exit => '+ rule.Id +'----------------------------');
                }//end workflow rule
            }//end sobject records
            
            
            if(toUpdateSObject.size()>0) update toUpdateSObject.values();
        
            try {
              if(childObjectList.size()>0) insert childObjectList;
            } catch (DmlException e) {
              System.debug('-----> Error has occured in workflow for Inserting child objects. Message: ' + e.getMessage());
            }
            
            if(WorkflowActionHelper.userIdMailContentMap!=null && WorkflowActionHelper.userIdMailContentMap.size()>0){
                         Map<Id,User> userDetails = WorkflowRuleHelper.getUserDetails(WorkflowActionHelper.userIdMailContentMap.keySet());
                         new WorkflowSendEmailUtil ().sendEmail(userDetails ,WorkflowActionHelper.userIdMailContentMap);
            }
           /*      
           if(grpsInSendEmailAction!=null & grpsInSendEmailAction.size()>0){
                //get the list of users in that group:-
                List<Group> grps =[Select Id,(Select UserOrGroupId FROM GroupMembers) FROM Group WHERE Id IN:grpsInSendEmailAction.keySet()];
                
                for(Group g:grps){
                     for(GroupMember gm:g.GroupMembers){
                            for( String objId : grpsInSendEmailAction.get(g.Id).keySet()){
                                    
                                   for(WorkflowRuleAction__c template :  grpsInSendEmailAction.get(g.Id).get(objId)){
                                        usersInSendEmailAction= WorkflowActionHelper.buildListForEmail(usersInSendEmailAction, gm.UserOrGroupId, template,objId);
                                   }  
                                    
                            }
                     }
                }
                
           }
           */
           //finally sending emails :-
           if(usersInSendEmailAction!=null &&   usersInSendEmailAction.size()>0){
                  Map<Id,User> userDetails = WorkflowRuleHelper.getUserDetails(usersInSendEmailAction.keySet());
                  new WorkflowSendEmailUtil ().sendEmail(userDetails ,usersInSendEmailAction);
           } 
            
		System.debug('----> Evaluate Workflow Rules: Exit');
        return true; 
    }
    
        /*
        @purpose:
            method evaluates the rule to true/false for the sobject record
        */
        private static Boolean evaluateRule(SObject so,WorkflowRule__c rule){ 
            Boolean evaluateRule = true;
    		if(isUpdate  && rule.Evaluation_Rule__c.equals('Record is created or edited and did not previously meet the rule criteria')){
                evaluateRule =false;
                if(oldListMap != null && oldListMap .size()>0 && oldListMap.get(so.Id)!=null){
                   SOBject obj= oldListMap.get(so.Id);
                   for(WorkflowRuleCriteria__c criteria :rule.Workflow_Rule_Criterias__r){ 
                        /* For cross formula fields the evaluation created or edited and did not previously meet does not work 
                           cross formula fields are located in other objects and we do not have a way to trap the change*/
                        if(criteria.Child_Relationship_Name__c!=null || criteria.Parent_Object_Field__c!=null){
                   			evaluateRule =false;
                   			continue;
                   		}
                        if(so.get(criteria.Field_API_Name__c) != obj.get(criteria.Field_API_Name__c)){
                            evaluateRule = true;
                            break;
                        }
                   } 
                }           
            }
    		if(!evaluateRule ) return false; 
    		
            //CRITERIA LOGIC
            Set<Boolean> results= new Set<Boolean>();
            String filterLogic = rule.Filter_Logic__c;
            
            for(WorkflowRuleCriteria__c criteria :rule.Workflow_Rule_Criterias__r){ 
                	System.debug('----> Criteria: ' + criteria);
                    //evaluate each criteria to decide
                    if(criteria.Child_Relationship_Name__c!=null){
                        //evaluate child records
                        Boolean childResult=true;
                        for(SObject cso : so.getSObjects(criteria.Child_Relationship_Name__c)){
                            if(checkCriteria(String.valueof(cso.get(criteria.Field_API_Name__c)),criteria)){
                                childResult=false;
                                break;
                            }
                        }
                        results.add(childResult);
                    }else if(String.isBlank(criteria.Parent_Object_Field__c)){
                        results.add(checkCriteria(String.valueof(so.get(criteria.Field_API_Name__c)),criteria));
                        System.debug('----> IS BLANK result: ' + checkCriteria(String.valueof(so.get(criteria.Field_API_Name__c)),criteria));
                    }else if(!String.isBlank(criteria.Parent_Object_Field__c)){
                        SObject pso = so.getSObject(criteria.relationship_name__c);
                        results.add(pso!=null ? checkCriteria(String.valueof(pso.get(criteria.Parent_Object_Field__c)),criteria):false);
                    }
            }
            return  (rule.Filter_Logic__c == 'AND' ? !results.contains(false) : results.contains(true));
        }

        private static Boolean checkCriteria(String fieldValue,WorkflowRuleCriteria__c criteria){
                
            Boolean result=false;
            
            //support null / is null operator
            if(criteria.Operator__c.equalsIgnoreCase('Is Null') || criteria.Operator__c.equalsIgnoreCase('Is Not Null')){
                     result =  WorkflowComparisonHelper.isValid(fieldValue,criteria.Value__c,criteria.Operator__c); 
                     return result;
            }
                        
            if (!String.isBlank(fieldValue)){ 
            	
            	String comparisonValue = criteria.Value__c;
            	
            	String fieldtype = criteria.Field_Type__c;
                // Check the field type
		        if (fieldType == 'integer' || fieldType == 'double'){
		        	result = WorkflowComparisonHelper.isValid(decimal.valueOf(fieldValue),decimal.valueOf(comparisonValue),criteria.Operator__c,criteria); 		           
		        }else if (fieldType == 'date'){
		        	result = WorkflowComparisonHelper.isValid(WorkflowRuleUtils.convertStringToDate(fieldValue), WorkflowRuleUtils.convertStringToDate(comparisonValue),criteria.Operator__c,criteria); 		            
		        }else if (fieldType == 'datetime'){
		        	result = WorkflowComparisonHelper.isValid(WorkflowRuleUtils.convertStringToDateTime(fieldValue), WorkflowRuleUtils.convertStringToDateTime(comparisonValue),criteria.Operator__c,criteria); 	            
		        }else{
		        	result = WorkflowComparisonHelper.isValid(fieldValue,comparisonValue,criteria.Operator__c);		            
		        }                             
            }
            return result;
                
        }
        


    
    
    /**
    * this method   gets all the fields involved in the criteria for evaluation
    */
    private  static void initFieldInvolvedInCriteria(List<WorkflowRule__c> rules ,String sobjectName){
    
        criteriaFields = new Map<String,Set<String>>();                               
        for(workflowRule__c rule:rules){
            for(WorkflowRuleCriteria__c criteria :rule.Workflow_Rule_Criterias__r){             
                system.debug('WorkflowRuleCriteria__c-->'+criteria);
               //for the main object if the relation ship is not defined take the rule object
               String key = criteria.Child_Relationship_Name__c!=null ? criteria.Child_Relationship_Name__c.toLowerCase() : criteria.Criteria_Object__c.toLowerCase(); 
                 
               String field =  criteria.Parent_Object_Field__c!=null?  criteria.Relationship_Name__c+'.'+criteria.Parent_Object_Field__c : criteria.Field_API_Name__c;
                   
               Set<String> fieldToAdd = criteriaFields.get(key)!=null ? criteriaFields.get(key): new Set<String>();            
               if(!fieldToAdd.contains(field.toLowerCase()))fieldToAdd.add(field.toLowerCase());
               criteriaFields.put(key,fieldToAdd);
             }           
        }
       
    }
    
    private static void applyUpdateAction(WorkflowRuleAction__c action,SObject o){
        SObject o1 =  action.Field_Name__c=='CrossObject' &&  !action.CrossObjectField__c.startsWithIgnoreCase('{!What') ? o.getSObject(action.CrossObjectField__c.substringbetween('{!','}').split('\\.')[0]): o;
        
        if(o1!=null && action.ActionType__c == 'Update Field'){
            
            o1= toUpdateSObject.get(String.valueof(o1.get('id'))) ==null?
                o1 : toUpdateSObject.get(String.valueof(o1.get('id')));
            
            String value = WorkflowActionHelper.getValueForUpdateAction(action);
            String fieldToUpdate = action.Field_Name__c=='CrossObject' ? action.CrossObjectField__c.substringbetween('{!','}').split('\\.')[1] :action.Field_Name__c;
                         
           
            if(action.child_relationship_name__c!=null){
                //update child objects
                //itz a action on the child object:-               
                for(SObject co :o.getSObjects(action.child_relationship_name__c)){
                     if(value!=null){
                        value =   WorkflowMergeFormulaHelper.resolveValueFetched (action,value,co); 
                        co = WorkflowActionHelper.updateField(action,action.field_name__c,action.value__c,co);
                        toUpdateSObject.put(String.valueof(co.get('id')),co);
                     }
                }                
                return;
            }
            else if(action.Field_Name__c=='CrossObject' && action.CrossObjectField__c.substringbetween('{!','}').startsWithIgnoreCase('What')){
                //get the what id from task & update the parent:-
                SObject taskObj = Database.query('Select WhatId FROM Task WHERE Id =\''+String.valueof(o1.get('id'))+'\'');     
                //once task object if fetched
                String whatid= String.valueOf(taskObj.get('WhatId'));
                //finnaly get the parent object & field update will then be spl
                o1 = toUpdateSObject.get(whatid);
                if(o1==null){
                    //now get the sobject:-
                    o1 =Database.query('Select '+fieldToUpdate+' FROM '+String.valueof(Id.valueOf(whatid).getSObjectType())+' WHERE Id=\''+whatid+'\'');
                }                           
            }
           /*else {
                o1 = WorkflowActionHelper.updateField(action,fieldToUpdate,value,o1);
                toUpdateSObject.put(String.valueof(o1.get('id')),o1);   
           }
           */
           
            if(value!=null){                     
                value =   WorkflowMergeFormulaHelper.resolveValueFetched (action,value,o); 
                o1 = WorkflowActionHelper.updateField(action,fieldToUpdate,value,o1);
                toUpdateSObject.put(String.valueof(o1.get('id')),o1);         
            }
                 
        }
                           
    }
    
   
}