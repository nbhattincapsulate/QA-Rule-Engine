public with sharing class WorkflowRuleCriteriaController {
    
    public ApexPages.standardController                     stdController               {get; set;}
    public List<WorkflowRuleCriteria>                       workflowCriteriaList        {get; set;}
   
    public Integer                                          counter                     {get; set;}

    /*
    * @Description : Constructor taking standard controller as a parameter 
    */
    public WorkflowRuleCriteriaController(ApexPages.standardController controller) {
        this.stdController = controller;

        // Set up workflow rule criteria 
        setUpWorkflowRuleCriteria(this.stdController.getId());
    }

    /*
    * @description : Get all the objects from the org
    * @return List<SelectOption>  Sorted objects by its label
    */
    public List<SelectOption> getOrgObjects(){
        List<SelectOption> options = new List<SelectOption>();

        // Get all the objects in the org 
        for (Schema.sObjectType obj : Schema.getGlobalDescribe().values()){
            options.add(new SelectOption(obj.getDescribe().getName().toLowerCase(), obj.getDescribe().getLabel()));
        }
        return WorkflowRuleUtils.selectOptionSortByLabel(options);
    }

    /*
    *  @Description : Method used to set up workflow rule criteria 
    *  @Return void
    */
    private void setUpWorkflowRuleCriteria(Id workflowRuleId){
        this.workflowCriteriaList = new List<WorkflowRuleCriteria>();
       
        Map<String, Map<String, Schema.sObjectField>> mapSchema = new Map<String, Map<String, Schema.sObjectField>>();
        
        // check Id is not null
        if (workflowRuleId != null){
            // Get all the scoring rule related to the scoring rule 

            WorkflowRule__c workflowRule = [SELECT Id, Object_Name__c, (SELECT Id, Field_API_Name__c, Field_Type__c, Operator__c, Parent_Object_Field__c, 
                                                        Parent_Object_Name__c, Value__c, Relationship_Name__c,Criteria_Object__c,Child_Relationship_Name__c 
                                                            FROM Workflow_Rule_Criterias__r) 
                                                        
                                                    FROM WorkflowRule__c WHERE Id=: workflowRuleId LIMIT 1];
            
            // Get the object name schema
            List<SelectOption> objOptions = new List<SelectOption>();
            
            if (!String.isBlank(workflowRule.Object_Name__c)) objOptions =WorkflowRuleUtils.populateChildObjects(workflowRule.Object_Name__c);                                        
            
            // Loop through each workflow rule criteria 
            for (WorkflowRuleCriteria__c criteria : workflowRule.Workflow_Rule_Criterias__r){
                
                if (!String.isBlank(criteria.Criteria_Object__c)) mapSchema = WorkflowRuleUtils.getSchemaMap(criteria.Criteria_Object__c);
                
                // Get the object name 
                String objectName = (String.isBlank(criteria.Parent_Object_Name__c) ?  criteria.Criteria_Object__c : criteria.Parent_Object_Name__c);
                
                String criteriaObject = criteria.Criteria_Object__c;
                
                // Get the map
                mapSchema = WorkflowRuleUtils.getSchemaMap(objectName);
                
                if(criteria.child_relationship_name__c!=null) criteria.Criteria_Object__c = criteria.Criteria_Object__c+'~'+criteria.child_relationship_name__c;
                
                this.workflowCriteriaList.add(new WorkflowRuleCriteria(this.workflowCriteriaList.size() + 1,
                                                                     criteria,
                                                                     objectName, 
                                                                     WorkflowRuleUtils.getFields(mapSchema.get(criteriaObject)), 
                                                                     (!String.isBlank(criteria.Parent_Object_Name__c) ? WorkflowRuleUtils.getFields(mapSchema.get(criteria.Parent_Object_Name__c.toLowerCase())) : new List<SelectOption>()),objOptions));
            }

            
        }
    }
    
    

    /*
    * @Description : Method used to show the criteria fields
    * @Return PageReference  null
    */
    public PageReference showCriteria(){
        this.workflowCriteriaList = new List<WorkflowRuleCriteria>();
        
        // Add a new criteria 
        addCriteria();

        return null;
    }


    /*
    * @Description : Method used to add a new criteria 
    * @Return PageReference  null
    */
    public PageReference addCriteria(){
        WorkflowRule__c workflowRule = (WorkflowRule__c)this.stdController.getRecord();
        system.debug('workflowRule-->'+workflowRule.Object_Name__c);
        // Check if object name is not blank
        if (!String.isBlank(workflowRule.Object_Name__c)){
            Map<String, Map<String, Schema.sObjectField>> mapSchema = WorkflowRuleUtils.getSchemaMap(workflowRule.Object_Name__c.toLowerCase());
            
            //also setupChildObjects:-
            List<SelectOption> objOptions =WorkflowRuleUtils.populateChildObjects(workflowRule.Object_Name__c);
            system.debug('objOptions-->'+objOptions);
            //WorkflowRuleUtils.getFields(mapSchema.get(workflowRule.Object_Name__c.toLowerCase()))
            this.workflowCriteriaList.add(new WorkflowRuleCriteria(this.workflowCriteriaList.size() + 1,new WorkflowRuleCriteria__c(Criteria_Object__c=workflowRule.Object_Name__c),workflowRule.Object_Name__c, new List<SelectOption>(), new List<SelectOption>(),objOptions));
        }

        return null;
    }
    
 

    /*
    * @Description : Method used to remove a selected criteria
    * @Return PageReference  null
    */
    public PageReference deleteCriteria(){
        // Check counter is not null
        if (counter != null && counter > 0) {
                this.workflowCriteriaList.remove(counter-1);
        }
        return null;
    }
    
    public void showObjectFields(){
        if (counter != null && counter > 0) {  
            
            if( !String.isBlank(this.workflowCriteriaList[counter-1].workflowRuleCriteria.Criteria_Object__c)){
            	String obj = this.workflowCriteriaList[counter-1].workflowRuleCriteria.Criteria_Object__c.split('~')[0];
            
            	Map<String, Map<String, Schema.sObjectField>> mapSchema = WorkflowRuleUtils.getSchemaMap(obj.toLowerCase());
            	this.workflowCriteriaList[counter-1].objectFields=  WorkflowRuleUtils.getFields(mapSchema.get(obj.toLowerCase()));
            }else{
            	this.workflowCriteriaList[counter-1].clearValues();
            	this.workflowCriteriaList[counter-1].objectFields = new List<SelectOption>();
            }
        }
    }


    /*
    * @Description : Method used to save the scoring rule and its criteria 
    * @Return PageReference  null
    */
    public PageReference saveWorkflowRule(){
        WorkflowRule__c workflowRule = (WorkflowRule__c)this.stdController.getRecord();
        List<WorkflowRuleCriteria__c> workflowRuleCriteriaToUpsert  = new List<WorkflowRuleCriteria__c>();
        
        // Create arule
        try{
            // Create a  rule  
            upsert workflowRule;
          
            // Insert the new  criteria rules 
            for (WorkflowRuleCriteria criteria : this.workflowCriteriaList){
                
                if(criteria.workflowRuleCriteria.Id==null) criteria.workflowRuleCriteria.Workflow_Rule__c = workflowRule.Id;
                if(String.isBlank(criteria.workflowRuleCriteria.Criteria_Object__c)) continue;
                
                criteria.workflowRuleCriteria.Criteria_Object__c = criteria.workflowRuleCriteria.Criteria_Object__c .split('~')[0];                
                String selectedField = (!String.isBlank(criteria.workflowRuleCriteria.Parent_Object_Name__c) ? criteria.workflowRuleCriteria.Parent_Object_Field__c : criteria.workflowRuleCriteria.Field_API_Name__c);
                //criteria.workflowRuleCriteria.Value__c = (!String.isBlank(selectedField) ? String.valueOf(criteria.dataObject.get(selectedField)) : '');
                
                
                workflowRuleCriteriaToUpsert.add(criteria.workflowRuleCriteria);
            }

            // If rule criteria is not empty 
            if (!workflowRuleCriteriaToUpsert.isEmpty()) upsert workflowRuleCriteriaToUpsert;
            
            Map<Id,WorkflowRuleCriteria__c> criteriaPresent = new Map<Id,WorkflowRuleCriteria__c>(workflowRuleCriteriaToUpsert);
            
            delete [Select Id FROM WorkflowRuleCriteria__c WHERE Id NOT IN:criteriaPresent.keySet() AND Workflow_Rule__c=: workflowRule.Id];
         

            // Return to the scoring rule detail page 
            return new ApexPages.standardController(workflowRule).view();
        }catch(Exception ex){(
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())));
           system.debug('error-->'+ex.getStackTraceString());
            
        }
        return null;
    }
    

    
    
    /*
    *  Wrapper Class for criteria
    */
    public class WorkflowRuleCriteria{
        public WorkflowRuleCriteria__c  workflowRuleCriteria        {get; set;}
        public sObject                      dataObject                  {get; set;} 
        public String                       objectName                  {get; set;}
        public String                       selectedField               {get; set;}
        public List<SelectOption>           criteriaObjects             {get; set;} 
        public List<SelectOption>           objectFields                {get; set;} 
        public List<SelectOption>           parentObjectFields          {get; set;} 
        public Integer                      counter                     {get; set;}
		
		public boolean iseditable{set;get;}
        public boolean isbetween{set;get;}
        public boolean isPicklist{set;get;}
        public boolean isBoolean{set;get;}
        public boolean ismultiselect{set;get;}
        
        //store the operators
        public List<SelectOption> operators {get;set;}
        
        //store the picklist values if any
		public List<SelectOption> picklistvalues {get;set;}
		
        /*
        * Costructor 
        */
        public WorkflowRuleCriteria(Integer counter,WorkflowRuleCriteria__c workflowRuleCriteria, String objectName, List<SelectOption> objectFields, List<SelectOption> parentObjectFields, List<SelectOption> criteriaObjects){
            this.counter = counter;
            this.workflowRuleCriteria = workflowRuleCriteria;
            this.dataObject = Schema.getGlobalDescribe().get(objectName.toLowerCase()).newSObject();
            this.objectName = objectName;           
            this.objectFields = objectFields;
            this.parentObjectFields = parentObjectFields;
            this.selectedField = (String.isBlank(this.workflowRuleCriteria.Parent_Object_Name__c) ?  this.workflowRuleCriteria.Field_API_Name__c : this.workflowRuleCriteria.Parent_Object_Field__c);
            this.criteriaObjects = criteriaObjects;
            
            
            this.isbetween=false;
            this.isBoolean=false;
            this.isPicklist=false;
            this.ismultiselect=false;

            // Check selected value is not null
            //if (!String.isBlank(this.selectedField)) setObjectValue(this.workflowRuleCriteria.Field_Type__c,this.workflowRuleCriteria.Value__c); 
            /*
            	in edit mode ?
            */
            if(this.workflowRuleCriteria.id!=null){
            	setDisplayValues();
            }
        }
        
        
        private void setDisplayValues(){
        	
        	if (!String.isBlank(this.workflowRuleCriteria.Parent_Object_Field__c)){
        		Map<String, Map<String, Schema.sObjectField>> mapSchema = WorkflowRuleUtils.getSchemaMap(this.workflowRuleCriteria.Parent_Object_Name__c);
            	this.selectedField = this.workflowRuleCriteria.Parent_Object_Field__c;
            	Schema.DescribeFieldResult fdesc = mapSchema.get(this.workflowRuleCriteria.Parent_Object_Name__c).get(this.selectedField).getDescribe();
            	DisplayType fieldtype=fdesc.gettype();
	            this.operators = WorkflowRuleUtils.populateOperators(fieldtype);
	            
	            if(fieldType==Schema.DisplayType.Boolean)
	                this.isBoolean = true;
	            
	            //2. if display type is picklist ..populate the picklist values
	            if(fieldType==Schema.DisplayType.MultiPicklist||fieldType==Schema.DisplayType.Picklist ){
	            	this.isPicklist=true;  
	            	this.picklistvalues = WorkflowRuleUtils.populatePicklistValues(Schema.getGlobalDescribe().get(this.workflowRuleCriteria.Parent_Object_Name__c.toLowerCase()),this.workflowRuleCriteria.Parent_Object_Field__c);                    	
	            }
        	}else{
        		Map<String, Map<String, Schema.sObjectField>> mapSchema = WorkflowRuleUtils.getSchemaMap(this.workflowRuleCriteria.criteria_object__c.toLowerCase());
            	//this.selectedField = this.workflowRuleCriteria.Field_API_Name__c;
            	Schema.DescribeFieldResult fdesc = mapSchema.get(this.workflowRuleCriteria.criteria_object__c.toLowerCase()).get(this.selectedField).getDescribe();
            	DisplayType fieldtype=fdesc.gettype();
	            this.operators = WorkflowRuleUtils.populateOperators(fieldtype);
	            
	            if(fieldType==Schema.DisplayType.Boolean)
	                this.isBoolean = true;
	            
	            //2. if display type is picklist ..populate the picklist values
	            if(fieldType==Schema.DisplayType.MultiPicklist||fieldType==Schema.DisplayType.Picklist ){
	            	this.isPicklist=true;  
	            	this.picklistvalues = WorkflowRuleUtils.populatePicklistValues(Schema.getGlobalDescribe().get(this.objectName.toLowerCase()),this.workflowRuleCriteria.Field_API_Name__c);                    	
	            }
        	}
        }
        
        /*
        * @Description : Method used to set the object value based on its selected field type
        * @Return void
        */
        /*private void setObjectValue(String fieldType, String value){
            // Check value is not blank
            if (!String.isBlank(value)){
                // Integer type 
                if (fieldType == 'integer'){
                    this.dataObject.put(this.selectedField, WorkflowRuleUtils.convertStringToInteger(value));
                }else if (fieldType == 'double'){
                    this.dataObject.put(this.selectedField, WorkflowRuleUtils.convertStringToDouble(value));
                }else if (fieldType == 'boolean'){
                    this.dataObject.put(this.selectedField, WorkflowRuleUtils.convertStringToBoolean(value));
                }else if (fieldType == 'date'){
                    this.dataObject.put(this.selectedField, WorkflowRuleUtils.convertStringToDate(value));
                }else if (fieldType == 'datetime'){
                    this.dataObject.put(this.selectedField, WorkflowRuleUtils.convertStringToDateTime(value));
                } else{
                    this.dataObject.put(this.selectedField, value);
                } 
            }
          
        }  */ 

        /*
        * @Description : Method used to check whether the selected field is a parent field
        * @Return void
        */
        public void isReference(){
        	
        	if(String.isBlank(this.workflowRuleCriteria.criteria_object__c) || String.isBlank(this.workflowRuleCriteria.Field_API_Name__c)){
            	//reset the values:-
            	clearValues();
            }           
            
            if (!String.isBlank(this.workflowRuleCriteria.criteria_object__c) && !String.isBlank(this.workflowRuleCriteria.Field_API_Name__c)){
                this.objectName = this.workflowRuleCriteria.criteria_object__c.split('~')[0];
                this.selectedField = this.workflowRuleCriteria.Field_API_Name__c;
                Map<String, Map<String, Schema.sObjectField>> mapSchema = WorkflowRuleUtils.getSchemaMap(objectName);

                // check the selected field is a reference fields 
                List<Schema.sObjectType> objectTypes = mapSchema.get(objectName).get(this.workflowRuleCriteria.Field_API_Name__c).getDescribe().getReferenceTo();
                if (!objectTypes.isEmpty()){
                    getParentFields(objectTypes[0].getDescribe().getName().toLowerCase(),mapSchema);
                }else{
                    
                    this.workflowRuleCriteria.Parent_Object_Name__c = '';
                    this.workflowRuleCriteria.Parent_Object_Field__c = '';
                    
                    this.isBoolean = false;
                    this.isPicklist=false;
                    
                    this.dataObject = Schema.getGlobalDescribe().get(this.objectName.toLowerCase()).newSObject();
                    //set the field type of the field
                    Schema.DescribeFieldResult fdesc = mapSchema.get(objectName).get(this.workflowRuleCriteria.Field_API_Name__c).getDescribe();
                    this.workflowRuleCriteria.Field_Type__c = String.valueOf(fdesc.getSOAPType()).toLowerCase();
                    
                    //we need the display type also:
                    //1. populate operator based on display type
                    DisplayType fieldtype=fdesc.gettype();
                    this.operators = WorkflowRuleUtils.populateOperators(fieldtype);
                    
                    if(fieldType==Schema.DisplayType.Boolean)
                        this.isBoolean = true;
                    
                    //2. if display type is picklist ..populate the picklist values
                    if(fieldType==Schema.DisplayType.MultiPicklist||fieldType==Schema.DisplayType.Picklist ){
                    	this.isPicklist=true;  
                    	this.picklistvalues = WorkflowRuleUtils.populatePicklistValues(Schema.getGlobalDescribe().get(this.objectName.toLowerCase()),this.workflowRuleCriteria.Field_API_Name__c);                    	
                    }
                     
                    
                    this.workflowRuleCriteria.Field_Name__c = fdesc.getLabel();
                    this.parentObjectFields = new List<SelectOption>();
                }
            }
        }

        /*
        * @Description : Method used to get the parent fields
        * @Return void
        */
        public void getParentFields(String objectName, Map<String, Map<String, Schema.sObjectField>> mapSchema){
            this.objectName = this.workflowRuleCriteria.criteria_object__c.split('~')[0];
            this.workflowRuleCriteria.Parent_Object_Name__c = objectName;
            this.dataObject = Schema.getGlobalDescribe().get(objectName).newSObject();
            this.selectedField = '';

            // Get the field schema for the parent fields 
            if (!mapSchema.containsKey(this.workflowRuleCriteria.Parent_Object_Name__c.toLowerCase())){
                mapSchema.putAll(WorkflowRuleUtils.getSchemaMap(this.workflowRuleCriteria.Parent_Object_Name__c.toLowerCase()));
            }

            // Get the object name 
            if (!mapSchema.containsKey(this.objectName.toLowerCase())){
                mapSchema.putAll(WorkflowRuleUtils.getSchemaMap(this.objectName.toLowerCase()));
            }

            // Get the select List options 
            this.parentObjectFields.addAll(WorkflowRuleUtils.getFields(mapSchema.get(this.workflowRuleCriteria.Parent_Object_Name__c.toLowerCase())));
            this.workflowRuleCriteria.Relationship_Name__c = mapSchema.get(this.objectName).get(this.workflowRuleCriteria.Field_API_Name__c).getDescribe().getRelationshipName();
        }

        /*
        * @Description : Method used to set the parent object field as a selected field
        * @Return void
        */
        public void setParentField(){
            Map<String, Map<String, Schema.sObjectField>> mapSchema = WorkflowRuleUtils.getSchemaMap(this.workflowRuleCriteria.Parent_Object_Name__c);
            this.selectedField = this.workflowRuleCriteria.Parent_Object_Field__c;
            Schema.DescribeFieldResult fdesc = mapSchema.get(this.workflowRuleCriteria.Parent_Object_Name__c).get(this.selectedField).getDescribe();
            this.workflowRuleCriteria.Field_Type__c = String.valueOf(fdesc.getSOAPType()).toLowerCase();
            this.workflowRuleCriteria.Field_Name__c = fdesc.getLabel();
            //this.workflowRuleCriteria.Field_Type__c = String.valueOf(mapSchema.get(this.workflowRuleCriteria.Parent_Object_Name__c).get(this.selectedField).getDescribe().getSOAPType()).toLowerCase();
        
        	//we need the display type also:
            //1. populate operator based on display type
            DisplayType fieldtype=fdesc.gettype();
            this.operators = WorkflowRuleUtils.populateOperators(fieldtype);
            
            if(fieldType==Schema.DisplayType.Boolean)
                this.isBoolean = true;
            
            //2. if display type is picklist ..populate the picklist values
            if(fieldType==Schema.DisplayType.MultiPicklist||fieldType==Schema.DisplayType.Picklist ){
            	this.isPicklist=true;  
            	this.picklistvalues = WorkflowRuleUtils.populatePicklistValues(Schema.getGlobalDescribe().get(this.workflowRuleCriteria.Parent_Object_Name__c.toLowerCase()),this.workflowRuleCriteria.Parent_Object_Field__c);                    	
            }
        }
        
        public void clearValues(){
        	this.isbetween=false;
            this.isBoolean=false;
            this.isPicklist=false;
            this.ismultiselect=false;
            
            this.operators = new List<SelectOption>();
            this.picklistvalues =new List<SelectOption>();
            this.parentObjectFields=new List<SelectOption>();
        }
        
        
    }
}