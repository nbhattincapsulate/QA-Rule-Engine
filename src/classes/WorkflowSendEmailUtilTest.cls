/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class WorkflowSendEmailUtilTest {

    @isTest(SeeAllData=true) 
    public static void sendEmailTest2(){
        EmailTemplate e=[Select Id,Body FROM EmailTemplate LIMIT 1];
        WorkflowRule__c rule = new WorkflowRule__c(Name = 'Test Test Account',Object_Name__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule;
        
        List<WorkflowRuleCriteria__c> criteria = new List<WorkflowRuleCriteria__c>();
               WorkflowRuleCriteria__c c1 = new WorkflowRuleCriteria__c(Workflow_Rule__c=rule.id);
               c1.Field_API_Name__c='Industry';
               c1.Field_Type__c='Picklist';
               c1.Operator__c='Equals';
               c1.Value__c='Agriculture';
               c1.criteria_object__c='Account';
               criteria.add(c1);
        insert criteria;
        
        WorkflowRuleAction__c a1 = new WorkflowRuleAction__c(workflow_rule__c=rule.id,action_object__c='Contact',
                                                            field_name__c='CrossObject',CrossObjectField__c='Account.Type',ActionType__c='Send Email',User_Owner_Id__c=UserInfo.getUserId(),Email_Template__c=e.Id);
        insert a1;
        
        User u=[Select Id,Name,FirstName,Lastname,email FROM User WHERE Id =:UserInfo.getUserId()];
        Map<Id,User> user = new Map<Id,User>();
        user.put(u.Id,u);
        
        System.runAs(u) {
          Account a = new Account(Name='test');
          insert a;
          
          Contact c = new Contact ( FirstName='firstname',Salutation='Mr.',LastName='test',email='test@test.com');
          insert c;
          
           Lead l = new Lead (LastName='test',Company='test',email='test@test.com');
          insert l;
          
          //Map
          Map<String,Map<String,List<WorkflowRuleAction__c>>> userEmailInfo= new Map<String,Map<String,List<WorkflowRuleAction__c>>>();
          Map<String,List<WorkflowRuleAction__c>> data = new Map<String,List<WorkflowRuleAction__c>>();
          data.put(a.Id,new List<WorkflowRuleAction__c>{a1 });
          data.put(c.Id,new List<WorkflowRuleAction__c>{a1 });
          data.put(l.Id,new List<WorkflowRuleAction__c>{a1 });
          userEMailInfo.put(u.Id,data);
          Test.startTest();
            new WorkflowSendEmailUtil().sendEmail(user, userEmailInfo);
          Test.stopTest();
        }
        
       
    }
}