public with sharing class WorkflowRuleActionsController {  
 
    public WorkflowRuleAction__c newRuleAction{get;set;}
    public WorkflowRule__c rule ;
    public String objType   {get;set;}
    public String fieldType {get;set;}
    
    public List<SelectOption> objOptions    {get;set;}
    public List<SelectOption> allObjectOptions    {get;set;}
    
    Set<String> setRelatedObjName;
    
    public List<SelectOption> fieldOption   {get;set;} 
    
    public List<List<SelectOption>> emailoptions  {get;set;}
    
    //25/12 adding new variable to hold id-name for email options
    Map<Id,String> user_queue_names = new Map<Id,String>();
    
    public List<List<SelectOption>> emailTemplateOptions  {get;set;}
    
    String ruleActionId;
    public boolean edit {get;set;}
    public String helpTextMF{get;set;}
    
    Map<String, Schema.SObjectField> mapField;
    Map<String, Schema.SObjectField> maplookupField;
    String ruleObjType;
    Map<String,String> requiredFields{get;set;}
    Map<String,String> parentFieldNameInChild{get;set;}
    public Boolean isCrossFormula{ get; set;}
  
    
    public String sendEmailToString{ get; set;}
    Map<Id,EmailTemplate> emailTemplates{get;set;}
   
    public String selectedField {get;set;}
    public String calculateFormulaForReference{get;set;}
    public String value {get;set;}
    public List<WorkflowValues_for_Insert_Record__c> lstInsRelRec {get;set;}
    public String selectedRecordId {get;set;}
    private Set<String> setFieldNames = new Set<String>();
    
    Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
    
    public Sobject sobjInstance{get;set;}
  
    public static final String VALUE_ERROR ='Both Value field & user/queue field cannot be specified together ';
    public static String MERGE_ERROR ='Invalid syntax for merge field provided';
    
    public static String INSERTRELATEDOBJECT_ERROR ='One or more input fields for Insert Related Object Action are Invalid';
    public static String SENDEMAIL_ERROR ='Invalid Syntax for Distribution List field provided';
   
    
    public string selectedRefName{get;set;}
    public string nameField {get;set;}
    
    public static Set<String> setAvailableDataTypes = new Set<String>{'CHECKBOX','CURRENCY','DATE','DATETIME','EMAIL','INTEGER','PERCENT','PHONE','PICKLIST','MULTIPICKLIST','TEXT','TEXTAREA','DOUBLE','ENCRYPTEDSTRING','URL','STRING','BOOLEAN','REFERENCE','COMBOBOX'};
    /**
     * This field will decide if the input field should be rendered on the UI or not
     */
    public Boolean renderValueField {get;set;}
    private Set<String> setRelObjApiName = new Set<String>();
    public Boolean renderValueFieldForFormula {get;set;}
    
    /**
     * This set will have all set of audit field which will not be displayed on the UI
     */
    private Set<String> setAuditFields = new Set<String> {'CREATEDBYID','CREATEDDATE','LASTMODIFIEDBYID','LASTMODIFIEDDATE','SYSTEMMODSTAMP'};
  
    public WorkflowRuleActionsController (Apexpages.StandardController stdcon){
        renderValueFieldForFormula = true;
        parentFieldNameInChild = new Map<String,String>();
        requiredFields = new Map<String,String>();
        
        helptextMF='{!ObjectRelationShipName.Field} Eg:- {!Cases__r.Subject},{!Account.Phone},{!Owner.Id}';
 
        lstInsRelRec = new List<WorkflowValues_for_Insert_Record__c>();
        
        ruleActionId = stdcon.getId();
        newRuleAction = (WorkflowRuleAction__c)stdcon.getRecord();
        newRuleAction.ActionType__c='Update Field';
     
        Schema.DescribeSObjectResult objinfo = null;
        objOptions = new List<SelectOption>();
        edit=false;
        isCrossFormula=false;  
        
        if(ruleActionId!=null){
         /** 
          * Edit existing Record
          */ 
           
          
            edit=true;
            newRuleAction = [SELECT Name,
                                   Field_Name__c,ActionType__c,Reference_Id__c,
                                   User_Owner_Id__c,
                                   Notify_User__c,
                                   Email_Template__c,
                                   Long_Value__c,
                                   Action_Object__c,
                                   Workflow_Rule__c,Value__c ,
                                   CrossObjectField__c,
                                   Field_API_Name__c,
                                   workflow_rule__r.object_name__c,
                                   
                                   notified_user__c,
                                   Email_template_folder__c,
                                   additional_emails__c,
                                   Field_Type__c,
                                   Action_Label__c,
                                   External_Field_API_Name__c,
                                   ExternalId__c
                                   
                             FROM  WorkflowRuleAction__c
                             WHERE id=:ruleActionId];
                             
           
            objType = newRuleAction.Action_Object__c;
            ruleObjType=newRuleAction.workflow_rule__r.object_name__c;
            if(newRuleAction.ActionType__c=='Send Email'){
                Apexpages.currentPage().getParameters().put('folderId',newRuleAction.Email_template_folder__c);
                getTemplates(); 
            } 
            
            
         

            if(newRuleAction.ActionType__c == 'Insert Related Object' ){
                populatedRelatedRecInfo(newRuleAction.Id);
            }
                        
            
            
            if(newRuleAction.ActionType__c=='Send Email' && newRuleAction.User_Owner_Id__c!=null){
                Id sendTo = Id.valueof(newRuleAction.User_Owner_Id__c);                       
                if(sendTo.getSObjectType() == User.SobjectType ) sendEmailToString='User';
                else if(sendTo.getSObjectType() == Group.SobjectType )sendEmailToString='Queue';
                ApexPages.currentPage().getParameters().put('sendemailto',sendEmailToString);
                buildEmailOptionsValues();
           } 
           
           if(newRuleAction.Field_API_Name__c=='CrossObject')isCrossFormula=true; 
           
          
                    
         }
        else{
         /**
          * New Record
          */
          
             String action = ApexPages.currentPage().getParameters().get('action');
             edit=false;
             if(action!=null && action!='')newRuleAction.ActionType__c=action;
                
             rule = [SELECT  object_name__c 
                     FROM    WorkflowRule__c 
                     WHERE id=:newRuleAction.workflow_rule__c];
             if(rule!=null){
                newRuleAction.action_object__c = rule.object_name__c;
                objType = rule.object_name__c;
                ruleObjType = objType;
                
            }
         } 
            
         if(objType!= null){     
                          
            /**
             * Get list of child objects of object on which rule is defined
            **/ 
            objOptions= WorkflowRuleUtils.populateChildObjects(ruleObjType);         
            populateFields(objType);
        }
        WorkflowRuleUtils.selectOptionSortByLabel(objOptions);
       
        displayAssignmentPanel();
        
        if(edit){
            
            if(newRuleAction.Field_Type__c!= null &&   newRuleAction.Field_Type__c.equalsIgnoreCase('textarea')){
            
                sobjInstance.put(newRuleAction.Field_API_Name__c,newRuleAction.Long_Value__c);
            }
            else{
                
                try{
                     if(newRuleAction.Field_Type__c!= null && newRuleAction.Field_Type__c.equalsIgnoreCase('reference')){
                
                        //here making small change with refernce :-
                        if(newRuleAction.Reference_Id__c != null && newRuleAction.Reference_Id__c.startsWith('{!')) calculateFormulaForReference = newRuleAction.Reference_Id__c;
                        else
                          sobjInstance.put(newRuleAction.Field_API_Name__c,newRuleAction.Reference_Id__c);
                    
                    }else if(newRuleAction.Field_Type__c!= null && newRuleAction.Field_Type__c.equalsIgnoreCase('BOOLEAN')){
                        sobjInstance.put(newRuleAction.Field_API_Name__c,newRuleAction.value__c!=null?Boolean.valueOf(newRuleAction.value__c):false);
                   
                    }else if(newRuleAction.Field_Type__c!= null && newRuleAction.Field_Type__c.equalsIgnoreCase('INTEGER')){
                        sobjInstance.put(newRuleAction.Field_API_Name__c,newRuleAction.value__c!=null?Integer.valueOf(newRuleAction.value__c):null);
               
                     }else if(newRuleAction.Field_Type__c!= null && newRuleAction.Field_Type__c.equalsIgnoreCase('CURRENCY')){
                       sobjInstance.put(newRuleAction.Field_API_Name__c,newRuleAction.value__c!=null?Decimal.valueOf(newRuleAction.value__c):null);
                    }else if(newRuleAction.Field_Type__c!= null && newRuleAction.Field_Type__c.equalsIgnoreCase('DATE')){
                         
                         sobjInstance.put(newRuleAction.Field_API_Name__c,Date.valueof(newRuleAction.value__c));
                    }else{
                         if(newRuleAction.Field_API_Name__c!='CrossObject' )
                         {
                             
                             sobjInstance.put(newRuleAction.Field_API_Name__c,newRuleAction.value__c);
                           }
                    }
                }//end try
                catch(Exception e){
                    calculateFormulaForReference = newRuleAction.value__c;
                }
            }            
        }
     }
  
    public PageReference  getFieldNames(){
        
         objType= Apexpages.currentPage().getParameters().get('parentName');
         
         lstInsRelRec = new List<WorkflowValues_for_Insert_Record__c>();
         requiredFields = new Map<String,String>();
         fieldType = null;
         newRuleAction.Field_API_Name__c = '';
         populateFields(objType.split('~')[0]);
        
         return null; 
    }

    /** 
     * This method is used to populate the fields of given Object
     */
    public void populateFields(String objType){
       
         renderValueField = true;
         populatedRelatedRecInfo(ruleActionId);
         fieldOption= new List<SelectOption>();
         
         

         string parent = objType;
         
         Schema.SObjectType sobjTypeParent = gd.get(parent.tolowercase());
         
         sobjInstance = sobjTypeParent.newSObject();
        
         
         Schema.DescribeSObjectResult parentObjFields= sobjTypeParent.getDescribe();
         mapField = parentObjFields.fields.getMap();
        
         for(String fieldname:mapField.keySet()){
            Schema.SObjectField sfield = mapField.get(fieldname);
            Schema.DescribeFieldResult descResField = sfield.getDescribe();
            String fieldLabel = descResField.getLabel();
            
          
            if(parentFieldNameInChild != null && objType != null && parentFieldNameInChild.get(objType.tolowerCase())!=null && parentFieldNameInChild.get(objType.tolowerCase()).equalsIgnoreCase(fieldname))
                  continue;
            
            if(descResField.isNameField()){
                nameField = descResField.getName();
            }
            if(descResField.isCalculated() || !descResField.isCreateable()){ 
                continue;
            }
           
             
            if(!setAvailableDataTypes.contains(String.valueOf(descResField.getType()))){               
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'This object is not supported for insert now.');
                ApexPages.addMessage(msg);
                renderValueField = false;
                fieldOption = new List<SelectOption>();
                fieldOption.add(new SelectOption('Not Supported','----Not Supported----'));
                break;
            }
            
            if(!setFieldNames.contains(descResField.getName()) && 
                    !setAuditFields.contains(descResField.getName().toUpperCase())){
                if(fieldType == null){
                    fieldType = descResField.getName();
                }               
                fieldOption.add(new SelectOption(descResField.getName(),fieldLabel));
            }
            if(descResField.isCreateable() && !descResField.isNillable() && !descResField.isDefaultedOnCreate()){
                requiredFields.put(descResField.getName().tolowerCase(),descResField.getLabel());
            }
           
        }
       
        if(newRuleAction.ActionType__c == 'Update Field' || newRuleAction.ActionType__c == '' ||  newRuleAction.ActionType__c == null){
            fieldOption.add(new SelectOption('CrossObject','Cross Object Field'));
           
        }
        fieldOption= WorkflowRuleUtils.selectOptionSortByLabel(fieldOption);
       
        
        String fieldName = newRuleAction.Field_Name__c!=null ? newRuleAction.Field_Name__c:newRuleAction.field_API_Name__c;
        
        if(fieldName != null && fieldName != ''){
            
            fieldType = fieldName;
            newRuleAction.Field_API_Name__C = fieldType;
        } 
       
        
        displayAssignmentPanel();
        
    }
    
    public void buildEmailOptionsValues(){
        emailoptions= new List<List<SelectOption>>();
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select--'));
                        
        String sendemail= Apexpages.currentPage().getParameters().get('sendemailto');
        if(sendemail=='User'){
            for(User u :[Select Id,Name FROM User WHERE IsActive=true]){
                options.add(new SelectOption(u.Id,u.Name));
                user_queue_names.put(u.Id,u.Name);
                /*if(options.size() == 1000){
                    emailoptions.add(options);
                    options = new List<SelectOption>();
                }*/
            }
        
        }if(sendemail=='Chatter Groups'){
            for(CollaborationGroup  u :[Select Id,Name FROM CollaborationGroup ]){
                //emailoptions.add(new SelectOption(u.Id,u.Name));
                options.add(new SelectOption(u.Id,u.Name));
                user_queue_names.put(u.Id,u.Name);
                /*if(options.size() == 1000){
                    emailoptions.add(options);
                    options = new List<SelectOption>();
                }*/
            }
        
        }
        else{
            String query =' Select Id,Name FROM Group';
            if(sendemail=='Queue')query += ' WHERE Type=\'Queue\'';
            else query += ' WHERE Type=\'Regular\'';
            
            List<Group> grp=Database.query(query);
            for(Group g:grp){
                options.add(new SelectOption(g.Id,g.Name));
                user_queue_names.put(g.Id,g.Name);
                /*if(options.size() == 1000){
                    emailoptions.add(options);
                    options = new List<SelectOption>();
                }
               */
            }
        }
        if(options.size() > 0){
          emailoptions.add(options);
        }
}       

    
    public void displayAssignmentPanel(){
         
           
           isCrossFormula=false;
           
           calculateFormulaForReference='';
           if(fieldType=='CrossObject'){
               isCrossFormula=true;
               newRuleAction.Field_Type__c = 'string';
               newRuleAction.Field_API_Name__c = 'CrossObject';
           }else 
           
           if(fieldType != null && mapField.containsKey(fieldType.toLowerCAse())){
               Schema.SObjectField field =  mapField.get(fieldType.toLowerCAse());    
               Schema.DescribeFieldResult F = field.getDescribe();
               
               String fieldDataType = String.valueOf(field.getDescribe().getType());
               newRuleAction.Field_Type__c = fieldDataType;
               newRuleAction.Field_API_Name__c = field.getDescribe().getName();
        }else if(fieldType == null || fieldType == ''){
          renderValueField = false;
          newRuleAction.Field_API_Name__c = '';
        }
        
    } 
    
    
    
    private string selectedRecordName(string selectedId){
        if(mapField.containsKey(fieldType.toLowerCAse())){
           Schema.SObjectField field =  mapField.get(fieldType.toLowerCAse());    
           
          
           Schema.DescribeFieldResult F = field.getDescribe();
           
           List <Schema.sObjectType> sobjTypeList = f.getReferenceTo();
           
          
           if(sobjTypeList != null && sobjTypeList.size() > 0){
            List<Sobject> sobjList = new List<Sobject>();
            Id referenceId = Id.valueof(selectedId);
            
            
            String objectToQuery =sobjTypeList[0].getDescribe().getName();
            
           
            if(referenceId.getSObjectType() == User.SobjectType)
                 objectToQuery ='User';
            sobjList = Database.query('select Name from '+objectToQuery +' where id = \''+selectedId+'\'');//+namefield+
          
            if(sobjList != null && sobjList.size()>0){
                return (String)sobjList[0].get('Name');//namefield
            }
            
           }
           

        }   
        return '';
    }
    
    public PageReference saveRuleAction(){
            if(!doSave())
                return null;
            return(new PageReference('/'+newRuleAction.Workflow_Rule__c));
          
    }
    public PageReference saveAndNewRuleAction(){
            if(!doSave())
                return null;
                
            newRuleAction = new WorkflowRuleAction__c(workflow_rule__c=newRuleAction.workflow_rule__c,actiontype__c='Update Field'  );
            objType = ruleObjType;
            return(new PageReference('/apex/WorkflowRuleActions'));
                   
    }
    
    
    
    private Boolean doSave(){
      // Added fieldType null check to resolve null pointer exception
      
            
          
            newRuleAction.Action_Object__c = objtype.split('~')[0];
            
            newRuleAction.Child_Relationship_name__c = objtype.split('~').size()>1?objtype.split('~')[1]:null;
            
            newRuleAction.Field_Name__c =  fieldType;
           
            //updated the logic..instead calling validate merge field we directly call isValidValue to allow bo
             
            if(fieldType != null && fieldType.trim()=='CrossObject'){
                    String crossobject = newRuleAction.CrossObjectField__c.startsWith('{!')? newRuleAction.CrossObjectField__c.substringBetween('{!','}'):newRuleAction.CrossObjectField__c;
                    if(!validateMergeField(crossobject)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,WorkflowRuleActionsController.MERGE_ERROR));
                        return false;
                    }
            }
            
            if(newRuleAction.ActionType__c == 'Update Field' && fieldType != null &&  fieldType.trim()!='CrossObject' ){
               
                 if(newRuleAction.Field_Type__c.equalsIgnoreCase('textarea') ){
                    newRuleAction.Value__c = '';
                    newRuleAction.Long_Value__c  = String.valueOf(sobjInstance.get(newRuleAction.field_API_Name__c));
                  
                }else{
                    newRuleAction.Long_Value__c = '';
                    if(newRUleAction.Field_Type__c.equalsIgnoreCase('reference')){
                        
                        
                         if (calculateFormulaForReference== null || calculateFormulaForReference=='') {
                               newRuleAction.Reference_Id__c  =String.valueOf(sobjInstance.get(newRuleAction.field_API_Name__c));
                               newRuleAction.Value__c =selectedRecordName(newRuleAction.Reference_Id__c);
                          }
                         else {
                          newRuleAction.Reference_Id__c =calculateFormulaForReference;
                          newRuleAction.Value__c =calculateFormulaForReference;
                         }
                    }
                    else if(!newRUleAction.Field_Type__c.equalsIgnoreCase('string') ){
                       newRuleAction.Value__c =  calculateFormulaForReference== null || calculateFormulaForReference=='' ? String.valueOf(sobjInstance.get(newRuleAction.field_API_Name__c)):calculateFormulaForReference;
                    }
                    else{
                        
                         
                         newRuleAction.Value__c = String.valueOf(sobjInstance.get(newRuleAction.field_API_Name__c));
                        // newRuleAction.Value__c = String.valueOf(sobjInstance.get(newRuleAction.Value__c));
                    }   
                    
                    selectedRefName = '';
                  
                }
            }// Logic of new Send Emai type starts here ---- 
            else if (newRuleAction.ActionType__c == 'Send Email' &&!ValidateSendEmailParams()) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,WorkflowRuleActionsController.SENDEMAIL_ERROR));
                        return false;
            }
          
            else if(newRuleAction.ActionType__c == 'Insert Related Object' ){
                
                    if((newRuleAction.ActionType__c == 'Insert Related Object' ) && !isValidateInsertObject()){
                                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,WorkflowRuleActionsController.INSERTRELATEDOBJECT_ERROR));
                        return false;
                    }
                    
                newRuleAction.Value__c = '';
                newRuleAction.Field_Name__c = '';
                newRuleAction.Long_Value__c = '';
            }
            
           
           
            edit=false;
            
            //finally save the email template name if any
            if(newRuleAction.Email_Template__c!=null && newRuleAction.Email_Template__c!='' && emailTemplates.get(Id.valueof(newRuleAction.Email_Template__c))!=null ) 
                newRuleAction.EmailTemplateName__c = emailTemplates.get(Id.valueof(newRuleAction.Email_Template__c)).Name;
            
            Savepoint sp = Database.setSavepoint();
            try{
            
                //Here let us add the validation for merge field
                String value = newRuleAction.Field_Type__c.toLowerCase()=='textarea'? newRuleAction.Long_Value__c:newRuleAction.Value__c;
                if(!isValidValue(value)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,WorkflowRuleActionsController.MERGE_ERROR));
                    return false;
                }
               
                    
                Database.upsert(newRuleAction);
                if(newRuleAction.ActionType__c == 'Insert Related Object' ){
                    upsertRelateRec(newRuleAction.Id);
                }
                
                
                
                
            }
            catch(Exception e){
                ApexPages.addMessages(e);
                Database.rollback(sp);
                return false;
            }
            return true;
    }
    
   
    
    /* this method validates the input/output params */ 
    private boolean validateSendEmailParams(){
      boolean result =true;
       
      if (newRuleAction.Additional_Emails__c!=null && newRuleAction.Additional_Emails__c.containsAny(';')) result= false;
      if (newRuleAction.Additional_Emails__c!=null && newRuleAction.Additional_Emails__c.containsAny(' ')) result= false;
      
      return result;
    }
    
    /**
    * This method is used to validate insert related object 
    * It checks whether all the required fields are added in it or not 
    */
    private boolean isValidateInsertObject(){
        
        Set<String> tempFieldsRequired = new Set<String>();
        tempFieldsRequired.addAll(requiredFields.keySet());
        
      
        for(WorkflowValues_for_Insert_Record__c info: lstInsRelRec){
            if(info.value__c != null && info.value__c != ''){
                tempFieldsRequired.remove(info.Name.toLowerCase());
            }
        }
        if(parentFieldNameInChild != null && newRuleAction.Action_Object__c != null && 
            parentFieldNameInChild.get(newRuleAction.Action_Object__c.tolowerCase()) != null){
            string fieldName = parentFieldNameInChild.get(newRuleAction.Action_Object__c.tolowerCase()).tolowercase();
            if(tempFieldsRequired.contains(fieldName)){ 
                tempFieldsRequired.remove(fieldName);
            }
        }
        
        if(tempFieldsRequired.size() > 0){
            List<String> fieldList = new List<String>();
            for(String field: tempFieldsRequired){
                fieldList.add(requiredFields.get(field));   
            }
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Cannot enabled record because required field missing:'+String.join(fieldList,', ')));
            return false;
        }   
        return true;
    }
 
    public void createRelateRec(){
        WorkflowValues_for_Insert_Record__c insRelRec = new WorkflowValues_for_Insert_Record__c();
        insRelRec.Name = fieldType;
        if(newRUleAction.Field_Type__c.equalsIgnoreCase('reference')){
          
            if (calculateFormulaForReference== null || calculateFormulaForReference==''){
                          insRelRec.Reference_Id__c  =String.valueOf(sobjInstance.get(newRuleAction.field_API_Name__c));
                          insRelRec.Value__c  =selectedRecordName(insRelRec.Reference_Id__c);
                         // insRelRec.Value__c  =selectedRecordName(newRuleAction.Reference_Id__c);
            }
            else
            {
                 insRelRec.Reference_Id__c=calculateFormulaForReference;
                 insRelRec.Value__c  =calculateFormulaForReference;
            }
                           
           
        }
        else{           
            if(calculateFormulaForReference != null && calculateFormulaForReference.trim() != ''){
              insRelRec.Value__c  = calculateFormulaForReference;
            }else{
              insRelRec.Value__c  = String.valueOf(sobjInstance.get(newRuleAction.field_API_Name__c));
            }
        }
        sobjInstance.put(newRuleAction.field_API_Name__c,null);
        
        lstInsRelRec.add(insRelRec);
        for(WorkflowValues_for_Insert_Record__c rec: lstInsRelRec){
            setFieldNames.add(rec.Name);
        }
       
        populateFields(objType.split('~')[0]);
        
        displayAssignmentPanel();
    }
    /**
     * Getting all the related record configuration from rule action 
     */
    public void populatedRelatedRecInfo(Id ruleActionId){
       // renderValueField = false;
        if(lstInsRelRec.size() == 0){
            lstInsRelRec = [select Value__c,Name,Workflow_Rule_Action__c from WorkflowValues_for_Insert_Record__c where Workflow_Rule_Action__c =: ruleActionId];
            for(WorkflowValues_for_Insert_Record__c rec: lstInsRelRec){
                setFieldNames.add(rec.Name);
            }
        }
    }
    
     
    /**
     * Setting the value of rule action if for all the related object record fields ---- cloud challenger
     */
    private void upsertRelateRec(Id ruleActionId){
        for(WorkflowValues_for_Insert_Record__c info: lstInsRelRec){
            if(info.Workflow_Rule_Action__c == null){
                info.Workflow_Rule_Action__c = ruleActionId;
            }
        }       
        upsert lstInsRelRec;
    }
    
    
    
    /**
     * This funtion will be use to delete the record from the related when rule action is
     * insert related object
     */
    public void deleteRec(){        
        if(selectedRecordId != null && selectedRecordId != ''){
            Integer selectedIndex = -1;
            for(selectedIndex = 0; selectedIndex < lstInsRelRec.size() ;selectedIndex++){
                WorkflowValues_for_Insert_Record__c info = lstInsRelRec[selectedIndex];
                if(info.Name == selectedRecordId){
                    if(setFieldNames.contains(info.Name)){
                        setFieldNames.remove(info.Name);
                    }
                    break;
                }
            }
            WorkflowValues_for_Insert_Record__c info = lstInsRelRec[selectedIndex];
            if(info.Id != null){
                WorkflowValues_for_Insert_Record__c delRec = new WorkflowValues_for_Insert_Record__c(id= info.Id);
                Database.delete(delRec,false);
                lstInsRelRec = new List<WorkflowValues_for_Insert_Record__c>();
                populatedRelatedRecInfo(newruleAction.Id);
            }
            else{
                lstInsRelRec.remove(selectedIndex);
            }
            populateFields(objType);
        }
    }
    
    
    
     /*
    returns a list of Email templates
    @access : public
    @params : none
    @retrun : List<SelectOption>
    */
    public void getTemplates() {
        String FolderId= ApexPages.currentPage().getParameters().get('folderId');
        emailTemplateOptions = new List<List<SelectOption>>();
        emailTemplates = new Map<Id,EmailTemplate>([Select Id, Name  FROM EmailTemplate WHERE FolderId=:FolderId]);
        List<SelectOption> options = new List<SelectOption>{new SelectOption('','--None--')};
        for (EmailTemplate et: emailTemplates.values()){
            options.add(new SelectOption(et.Id, et.Name));
            /*if(options.size() == 1000){
                emailTemplateOptions.add(options);
                options = new List<SelectOption>();
            }*/
        }
        if(options.size() > 0){
          emailTemplateOptions.add(options);
        }
        
        //return options;
    }
    
    /* return list of folders */
    public List<SelectOption> getFolders(){
        
        List<SelectOption> options = new List<SelectOption>();
        Map<Id,Folder> folders= new Map<Id,Folder>([Select Id, Name  FROM FOLDER WHERE Type='Email' ]);
        options.add(new SelectOption('','--None--'));
        for (Folder et: folders.values()){
            options.add(new SelectOption(et.Id, et.Name));
        }
        return options;
    }
    
    
    /*
      validate if the value as merge fields in it 
    */
    private Boolean isValidValue(String value){
        String concatOp ='&';
        WorkflowRuleActionsController.MERGE_ERROR ='Invalid syntax for merge field provided';
        
        
        if(value==null || value=='' || (!value.contains(concatOp) && !value.contains('{!'))) return true;
        
        if(value.startsWith(concatOp) || value.endsWith(concatOp)) return false;
        List<String> splitValue= value.split(concatOp );
        
        List<string> mergeFields = new List<string>();
        //checking
        for(String s : splitValue){
           system.debug(s);
            s = s.trim();
            if(s.startsWith('\'')){
                //then it shuld end with '
                if(!s.endsWith('\''))
                    return false;
                    
                if(s.contains('{!'))
                    return false;    
                    
            }
            
            if(s.startsWith('{!')){
                //then it shuld end with }
                if(!s.endsWith('}'))
                    return false;
            }
            
            if(!s.startsWith('{!') && !s.startsWith('\'')){
               return false;
            }
            if(s.startsWith('{!'))
                mergeFields.add(s.substringBetween('{!','}'));
        }
        
        if(mergeFields.size()>0){
               return validateMergeField(String.join(mergeFields,','));
            
        }
        
        return true;
    }
    
    private Boolean validateMergeField(String field){
        
        //adding a fix for what id
        if(newRuleAction.Action_Object__c.toLowerCase()=='task' && field.startsWith('What')){
          //then return true - without validation as poly reference field throw exceptions 
          return true;
        }
        
        String soql='SELECT '+field+
                       ' FROM '+newRuleAction.Action_Object__c+' LIMIT 1';
            try{
                List<SObject> record = database.query(soql);
            }catch(Exception e){
                WorkflowRuleActionsController.MERGE_ERROR =e.getMessage();
                return false;
            }  
        return true;
    }
    
    
    public void showHideValueField(){
      if(renderValueFieldForFormula){
        renderValueFieldForFormula = false;  
      }else{
        renderValueFieldForFormula = true;
      }
    }
    
    
}