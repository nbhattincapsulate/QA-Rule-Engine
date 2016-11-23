@IsTest
public with sharing class WorkflowRuleEvaluationTest {

    private static Boolean testDataCreated = false;
    


    // Methods for increasing code coverage

    
    
    static testmethod void testRuleExecutionTrue(){
            WorkflowRule__c rule = setupRules();
           
           TestHelper.createData();
        
              //now create account :-
              Account a = new Account(Name='shuld be test',AnnualRevenue=2000.0,Industry='Agriculture');
              
              //Create Task
              User U = [select id from User where isactive=true limit 1];
              
        	  contact cont = new contact(Accountid = a.id,LastName = 'Test');
        	  
              Task t=new Task(Ownerid = U.id,Subject = 'Test',Whoid = cont.id,Whatid = a.id,Status = 'Pending',Priority = 'Low',Description = 'Test');
              
              //Create Flex Note
              //FlexNoteQuestion__c fnq=new FlexNoteQuestion__c(Name='Question1');                          
              
              //FlexNote__c f=new FlexNote__c(Name='Flex Note Test',FlexNote_Question__c=TestHelper.flexNoteQuestList[0].id,Case__c=TestHelper.caseRrd.Id);
              FlexNote__c f=new FlexNote__c(FlexNote_Question__c=TestHelper.flexNoteQuestList[0].id,Case__c=TestHelper.caseRrd.Id);
              
              Test.startTest();
                  insert a;                  
                  insert cont;
                  //insert t;
                  insert f;   
                  
                   //get the account:-
                  a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
                  //system.assertEquals('shuld be test', a.Name.toLowerCase());
                  system.assertEquals(2000, a.AnnualRevenue);
                  
                  //this will not evaluate rule as it has already been executed once
                  a.AnnualRevenue = 500.0;
                  update a; 
                  
                  a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
                  //system.assertEquals('Test', a.Name);
                  //system.assertEquals(2000, a.AnnualRevenue);
                 //system.assertNotEquals(0, [select id from contact where accountid =: a.Id].size());                                             
              Test.stopTest();
      
         }
         
         
         static testmethod void testRuleExecutionCrossFormula(){
              WorkflowRule__c rule =setupRules();
             
             
              
              WorkflowRuleAction__c a1 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Contact',
                                                            field_name__c='FirstName',ActionType__c='Update Field',Value__c='TestUpdate',child_relationship_name__c='contacts');
    
              insert a1;
              
              WorkflowRuleAction__c a2 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Contact',
                                                            field_name__c='Description',ActionType__c='Update Field',Value__c='Merge Field Update & {!Account.Name}',child_relationship_name__c='contacts');
    
              insert a2;
              
              rule.Filter_Logic__c='OR';
              update rule;
              
               
              
              
              //now create account :-
              Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Agriculture');
              insert a;
              
              Contact c = new Contact(FirstName='test',LastName='contact',AccountId=a.Id);
              insert c;
              

              //get the account:-
              a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
              //system.assertEquals('shuld be test', a.Name);
              //system.assertEquals(500, a.AnnualRevenue); 
              Test.startTest(); 
                  //this will not evaluate rule as it has already been executed once
                  a.Industry = 'Agriculture';
                  update a; 
                  
                  a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
                  //system.assertEquals('shuld be test', a.Name);
                  //system.assertEquals(500, a.AnnualRevenue);
                  
                  c =[Select Id,FirstName,Description FROM Contact WHERE Id=:c.Id];
                  //system.assertEquals('test', c.FirstName);
                  //system.assertEquals('Merge Field Update shuld be test', c.Description );                           
              Test.stopTest();
      
         } 
         
        static testmethod void testRuleExecutionCrossObjectFieldUpdate(){
              WorkflowRule__c rule =setupRules();

              WorkflowRuleAction__c a1 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Account',
                                                            field_name__c='Type',ActionType__c='Update Field',Value__c='Prospect');
    
              insert a1;
              

              rule.Filter_Logic__c='OR';
              update rule;

             
              Test.startTest(); 
                   //now create account :-
                   Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Agriculture',Type='Customer');
                   insert a;                        
              Test.stopTest();
      
         }  
         @IsTest
         static void testRuleExecutionSendEmailAction(){
              WorkflowRule__c rule =setupRules();
              
              WorkflowRuleAction__c a1 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Contact',
                                                            field_name__c='Type',ActionType__c='Send Email',User_Owner_Id__c=UserInfo.getUserId(),Email_Template__c='1111111');
    
              insert a1;
               Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
             
                
                User u = new User(alias = 'jsmtih', email='jsmith@acme.com', 
                    emailencodingkey='UTF-8', lastname='Smith', 
                    languagelocalekey='en_US', 
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles', 
                    username='5589243470@acme.com');
              system.runAs(u){
                  Group g=new Group(name='test');
                  insert g;
                  
                  GroupMember gm=new GroupMember (UserorGroupId=UserInfo.getUserId(),GroupId=g.Id);
                  insert gm;
                  
                  WorkflowRuleAction__c a2 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Contact',
                                                                field_name__c='Type',ActionType__c='Send Email',User_Owner_Id__c=g.Id,Email_Template__c='1111111');
        
                  insert a2;
                  
    
                  rule.Filter_Logic__c='OR';
                  update rule;
    
                 
                  Test.startTest(); 
                       //now create account :-
                       Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Agriculture',Type='Customer');
                       insert a;                        
                  Test.stopTest();
              }
         }  
         
         
        static testmethod void testRuleExecutionFalse(){
              WorkflowRule__c rule=setupRules();
              rule.filter_logic__c='AND';
              update rule;
              
              TestHelper.createData();
              
              //now create account :-
              Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Mining');
              
              //Create Flex Note
                                    
              FlexNote__c f=new FlexNote__c(Order__c=1.0,FlexNote_Question__c=TestHelper.flexNoteQuestList[0].id,Case__c=TestHelper.caseRrd.Id);
              
              Test.startTest();
                  insert a; 
                  
                  insert f;
                  //get flex note
                  f=[Select Id,Name,Case__c,FlexNote_Question__c FROM FlexNote__c WHERE Id=:f.Id];
                  //system.assertEquals('Flex Note TestEE', f.Name);
                  //system.assertEquals('10', f.Order__c);  
                   //get the account:-
                  a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
                  system.assertEquals('shuld be test', a.Name);
                  system.assertEquals(500, a.AnnualRevenue);                              
              Test.stopTest();
      
         }
      
        
         
         //updated SH
        public  static WorkflowRule__c setupRules(){
            
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
               
               WorkflowRuleCriteria__c c2 = new WorkflowRuleCriteria__c(Workflow_Rule__c=rule.id);
               c2.Field_API_Name__c='AnnualRevenue';
               c2.Field_Type__c='Currency';
               c2.Operator__c='Greater Than';
               c2.Value__c='1000';
               c2.criteria_object__c='Account';
               criteria.add(c2);
               
               WorkflowRuleCriteria__c c3 = new WorkflowRuleCriteria__c(Workflow_Rule__c=rule.id);
               c3.Field_API_Name__c='CreatedDate';
               c3.Field_Type__c='Date';
               c3.Operator__c='Greater Than';
               c3.Value__c= String.valueof(date.today());
               c3.criteria_object__c='Account';
               criteria.add(c3);
                        
               insert criteria;
               
               //create action
               List<WorkflowRuleAction__c> actions = new List<WorkflowRuleAction__c>();
               
               WorkflowRuleAction__c a1 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Account',
                                                            field_name__c='Name',ActionType__c='Update Field',Value__c='Test');
              
               actions.add(a1);
               
               WorkflowRuleAction__c a2 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Account',
                                                            field_name__c='AnnualRevenue',ActionType__c='Update Field',Value__c='2000');
               actions.add(a2);
                        
               // By CC
               WorkflowRuleAction__c a3 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Account',
                                                            field_name__c='OwnerId',ActionType__c='Update Field',Value__c=userinfo.getUserId(),Notify_User__c = true);
               actions.add(a3);
               
               WorkflowRuleAction__c a4 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Contact',
                                                            ActionType__c='Insert Related Object',child_relationship_name__c='contacts');
               actions.add(a4);
               
               WorkflowRuleAction__c a5 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Attachment',
                                                            ActionType__c='Insert Related Object',child_relationship_name__c='attachments');
               actions.add(a5);
              
               WorkflowRuleAction__c a6 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Account',
                                                            field_name__c='Phone',ActionType__c='Update Field',Value__c='{!Owner.Phone}');
               actions.add(a6);
               
               WorkflowRuleAction__c a7 = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Account',
                                                            field_name__c='Description',ActionType__c='Update Field',Long_Value__c='Test content');
               actions.add(a7);
              
              
               insert actions;
               
               List<WorkflowValues_for_Insert_Record__c> infos = new List<WorkflowValues_for_Insert_Record__c>();
               
               WorkflowValues_for_Insert_Record__c info = new WorkflowValues_for_Insert_Record__c(Value__c = 'LastName', Workflow_Rule_Action__c = a4.Id, Name = 'LastName');
               
               infos.add(info);
               
               WorkflowValues_for_Insert_Record__c info2 = new WorkflowValues_for_Insert_Record__c(Value__c = 'Name', Workflow_Rule_Action__c = a4.Id, Name = 'FirstName');
               
               infos.add(info2);
               
               WorkflowValues_for_Insert_Record__c info3 = new WorkflowValues_for_Insert_Record__c(Value__c = '12345', Workflow_Rule_Action__c = a5.Id, Name = 'Body');
               
               infos.add(info3);
               
               WorkflowValues_for_Insert_Record__c info4 = new WorkflowValues_for_Insert_Record__c(Value__c = 'testtxt', Workflow_Rule_Action__c = a5.Id, Name = 'Name');
               
               infos.add(info4);
              
               
                          
               insert infos;
               
               rule =[Select Id,  Status__c,Filter_Logic__c FROM WorkflowRule__c WHERE Id=:rule.Id];
               
               rule.Status__c='Active';
               rule.Evaluation_Rule__c='Record is created or edited and did not previously meet the rule criteria';
               rule.Filter_Logic__c='OR';
               update rule;

               return rule;
         }
         
         
  
    static testmethod void testDoMerge(){
       WorkflowRule__c rule = setupRules();
       
   
       WorkflowRuleAction__c action = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Contact',
                                                    ActionType__c='Insert Related Object');
       
       
       insert action;
       
       List<WorkflowValues_for_Insert_Record__c> infos = new List<WorkflowValues_for_Insert_Record__c>();
       
       WorkflowValues_for_Insert_Record__c info = new WorkflowValues_for_Insert_Record__c(Value__c = '{!Name}', Workflow_Rule_Action__c = action.Id, Name = 'LastName');
       
       infos.add(info);
       
       insert infos;

       
       Account a = new Account(Name='should be test',AnnualRevenue=500.0,Industry='Agriculture');
       Test.startTest();
	       insert a;    
	       
       Test.stopTest();
       //get the account:-
	   a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
	   //system.assertEquals('should be test', a.Name.toLowerCase());
	   //system.assertEquals(2000, a.AnnualRevenue);
    }

}