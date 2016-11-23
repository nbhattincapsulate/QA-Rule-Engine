public with sharing class WorkflowRuleHelper {
    
    	
	public static List<WorkflowRule__c> getWorkflowRuleDetails(Set<Id> ruleIds){
		return [Select Id,Name,Filter_Logic__c,Evaluation_Rule__c,
									   (Select Id,criteria_object__c,field_name__c,field_api_name__c,operator__c,field_type__c,value__c ,
									    parent_object_field__c,relationship_name__c,child_relationship_name__c
									    from Workflow_Rule_Criterias__r ),
									    (Select Id,Name,Action_Label__c,Notified_User__c,Reference_Id__c,Field_Type__c,
									     Field_Name__c,ActionType__c,Value__c,Long_Value__c,Action_Object__c,
									     Notify_user__c,Email_Template__c,User_Owner_Id__c,CrossObjectField__c,
									     Workflow_Rule__c,Additional_Emails__c,External_Field_API_Name__c,
									     externalid__c,Child_Relationship_Name__c
									     FROM Workflow_Rule_Actions__r)
									    FROM WorkflowRule__c where Active__c=true AND Id IN:ruleIds];   	
	}
	
	public static Map<Id,WorkflowRuleAction__c> getInsertRelatedRecordInfo(Set<Id> ruleIds){
        return new Map<Id,WorkflowRuleAction__c>([Select Id,(Select Name, Value__c,Reference_Id__c From Values_for_Action_Insert_Record__r ) from WorkflowRuleAction__c where Workflow_Rule__c in: ruleIds and (ActionType__c = 'Insert Related Object' )]);
    }
	
	
    
    public static Map<Id,User> getUserDetails(Set<String> userIds){
        return new Map<Id,User>([Select Name, FirstName,LastName,Id,Email from User where Id in: userIDs]);
    }
    
    
}