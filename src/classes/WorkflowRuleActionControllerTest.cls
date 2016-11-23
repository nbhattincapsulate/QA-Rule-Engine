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
private class WorkflowRuleActionControllerTest {

    public static testMethod void testConstructor(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        Test.startTest();
            WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
            
        Test.stopTest();
        system.assertNotEquals(manageRA.objType,null);
        
    }
    
    public static testMethod void testConstructorNew(){
        WorkflowRule__c rule = new WorkflowRule__c(Name = 'Test Test Account',Object_Name__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule; 
        WorkflowRuleAction__c ruleAction = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id);
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleAction);
        Test.startTest();
            WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        Test.stopTest();
        system.assertNotEquals(manageRA.objType,null);
     }   

    public static testMethod void testGetFieldNames(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        ApexPages.currentPage().getParameters().put('parentName','Account');
        Test.startTest();
            manageRA.getFieldNames();
        Test.stopTest();
        system.assertEquals(manageRA.fieldOption.size()>0,true);
    }
   
    public static testMethod void testDisplayQueueUserLookup(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        ApexPages.currentPage().getParameters().put('parentName','Account');
        manageRA.populateFields('Lead');
        Test.startTest();
                       
            manageRA.fieldType='OwnerId';
            manageRA.displayAssignmentPanel();
            
        Test.stopTest();
       
    }
    
    public static testMethod void testDisplayUserLookup(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        ApexPages.currentPage().getParameters().put('parentName','Account');
        manageRA.getFieldNames();       
        Test.startTest();
                
            manageRA.fieldType='OwnerId';
            manageRA.displayAssignmentPanel();
            
        Test.stopTest();
       
    }
    
    
    
    public static testMethod void testSaveRuleAction(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Name';
        Test.startTest();
        PageReference page = manageRA.saveRuleAction();
        Test.stopTest();
        system.assertEquals(page.getURL(),'/'+ruleA.Workflow_Rule__c);
    }

    public static testMethod void testSaveRuleLongTextAction(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Description';
        manageRA.newRuleAction.Field_API_Name__c='textarea';
        manageRA.newRuleAction.Value__c = null;


        manageRA.newRuleAction.Long_Value__c = 'Long Value';
       // manageRA.newRuleAction.Value__c =  manageRA.newRuleAction.Long_Value__c.abbreviate(5,1);
        Test.startTest();
        manageRA.displayAssignmentPanel();
        PageReference page = manageRA.saveRuleAction();
        Test.stopTest();
       // system.assertEquals(page.getURL(),'/'+ruleA.id);
        system.assertEquals(page.getURL(),'/'+ruleA.Workflow_Rule__c);
        
    }
    
    public static testMethod void testSaveAndNewRuleAction(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Name';
        Test.startTest();
        PageReference page = manageRA.saveAndNewRuleAction();
        Test.stopTest();
        system.assertEquals(page.getURL(),'/apex/WorkflowRuleActions');
    }

       public static testMethod void testSaveAndNewRuleValidateLongTextAction(){

        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Description';
        manageRA.newRuleAction.Value__c = null;

        manageRA.newRuleAction.Long_Value__c = 'Long Value';

        Test.startTest();
        manageRA.displayAssignmentPanel();
        PageReference page = manageRA.saveAndNewRuleAction();
        Test.stopTest();
        system.assertEquals(page.getURL(),'/apex/WorkflowRuleActions');
    }


    
    public static testMethod void testSaveAndNewRuleOwnerUserAction(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'OwnerId';
        manageRA.newRuleAction.Value__c = null;
        manageRA.newRuleAction.Long_Value__c = null;
        manageRA.newRuleAction.Reference_Id__c = userinfo.getuserId();
        Test.startTest();
        PageReference page = manageRA.saveAndNewRuleAction();
        Test.stopTest();
        system.assertEquals(page.getURL(),'/apex/WorkflowRuleActions');
    }
    
    public static testMethod void testSaveandNewRuleOwnerQueueAction(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'OwnerId';
        manageRA.newRuleAction.Value__c = null;
        manageRA.newRuleAction.Long_Value__c = null;
        Group g = new Group(Name = 'Test acc queue');
        g.Type = 'Queue';
        insert g;
        manageRA.newRuleAction.Reference_Id__c= g.Id;
        Test.startTest();
        PageReference page = manageRA.saveAndNewRuleAction();
        Test.stopTest();
        system.assertEquals(page.getURL(),'/apex/WorkflowRuleActions');
    }

    
     public static testMethod void testSaveRuleOwnerUserAction(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'OwnerId';
        manageRA.newRuleAction.Value__c = null;
        manageRA.newRuleAction.Long_Value__c = null;
        manageRA.newRuleAction.Reference_Id__c = userinfo.getuserId();
        Test.startTest();
        PageReference page = manageRA.saveRuleAction();
        Test.stopTest();
      //  system.assertEquals(page.getURL(),'/'+ruleA.id);
        system.assertEquals(page.getURL(),'/'+ruleA.Workflow_Rule__c);
    }
    
    public static testMethod void testSaveRuleOwnerQueueAction(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'OwnerId';
        manageRA.newRuleAction.Value__c = null;
        manageRA.newRuleAction.Long_Value__c = null;
        Group g = new Group(Name = 'Test acc queue');
        g.Type = 'Queue';
        insert g;
        manageRA.newRuleAction.Reference_Id__c= g.Id;
        Test.startTest();
        PageReference page = manageRA.saveRuleAction();
        Test.stopTest();
        //system.assertEquals(page.getURL(),'/'+ruleA.id);
        system.assertEquals(page.getURL(),'/'+ruleA.Workflow_Rule__c);
    }
     
    
    public static testMethod void testCreateRelateRec(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Name';
        manageRA.newRuleAction.Reference_Id__c=Userinfo.getUserId();
        manageRA.newRuleAction.Value__c='testvalue';
        Test.startTest();
        manageRA.createRelateRec();
        Test.stopTest();
        System.assertEquals(1, manageRA.lstInsRelRec.size());
    }
    public static testMethod void testCreateRelateRecLongValue(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Description';
        manageRA.newRuleAction.Reference_Id__c=Userinfo.getUserId();
        manageRA.newRuleAction.Value__c = null;
        manageRA.newRuleAction.Long_Value__c='testvalue';
        Test.startTest();
        manageRA.createRelateRec();
        Test.stopTest();
        System.assertEquals(1, manageRA.lstInsRelRec.size());
    }
    
    public static testMethod void testDeleteRec(){
        //WorkflowRule__c rule = new WorkflowRule__c(name='Test Rule Test',Object_Name__c='Account');
        WorkflowRule__c rule = new WorkflowRule__c(Name = 'Test Test Account',Object_Name__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule; 
        WorkflowRuleAction__c ruleAction = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Contact',
                                                            field_name__c='LastName',ActionType__c='Insert Related Object',Value__c='Test');
        insert ruleAction ;
        
        WorkflowValues_for_Insert_Record__c info = new WorkflowValues_for_Insert_Record__c();
        info.Name = 'LastName';
        info.Value__c = 'Test';
        info.Workflow_Rule_Action__c = ruleAction.Id;
        insert info;
        
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleAction);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'LastName';
        manageRA.newRuleAction.Reference_Id__c=Userinfo.getUserId();
        manageRA.newRuleAction.Value__c='testvalue';
        manageRA.selectedRecordId = 'LastName';
        Test.startTest();
        manageRA.deleteRec();
        Test.stopTest();
        System.assertEquals(0, manageRA.lstInsRelRec.size());
    }
    
    public static testMethod void testSaveActionRelatedObj(){
       // WorkflowRule__c rule = new WorkflowRule__c(name='Test Rule Test',Object_Name__c='Account');
        WorkflowRule__c rule = new WorkflowRule__c(Name = 'Test Test Account',Object_Name__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule; 
        WorkflowRuleAction__c ruleAction = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Contact',
                                                            field_name__c='LastName',ActionType__c='Insert Related Object',Value__c='Test');
        insert ruleAction ;
        
        WorkflowValues_for_Insert_Record__c info = new WorkflowValues_for_Insert_Record__c();
        info.Name = 'LastName';
        info.Value__c = 'Test';
        info.Workflow_Rule_Action__c = ruleAction.Id;
        insert info;
        
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleAction);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'LastName';
        manageRA.newRuleAction.Reference_Id__c=Userinfo.getUserId();
        manageRA.newRuleAction.Value__c='testvalue';
        manageRA.selectedRecordId = 'LastName';
        Test.startTest();
        PageReference page = manageRA.saveRuleAction();
        Test.stopTest();
       // system.assertEquals(page.getURL(),'/'+ruleAction.id);
         system.assertEquals(page.getURL(),'/'+ruleAction.Workflow_Rule__c);
        
    }
    
    public static testMethod void testSaveAndNewActionRelatedObj(){
        //WorkflowRule__c rule = new WorkflowRule__c(name='Test Rule Test',Object_Name__c='Account');
        WorkflowRule__c rule = new WorkflowRule__c(Name = 'Test Test Account',Object_Name__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule; 
        WorkflowRuleAction__c ruleAction = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Asset',
                                                            field_name__c='Name',ActionType__c='Insert Related Object',Value__c='Test');
        insert ruleAction ;
        
        WorkflowValues_for_Insert_Record__c info = new WorkflowValues_for_Insert_Record__c();
        info.Name = 'Name';
        info.Value__c = 'Test';
        info.Workflow_Rule_Action__c = ruleAction.Id;
        insert info;
        
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleAction);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Name';
        manageRA.newRuleAction.Reference_Id__c=Userinfo.getUserId();
        manageRA.newRuleAction.Value__c='testvalue';
        manageRA.selectedRecordId = 'Name';
        ApexPages.currentPage().getParameters().put('parentName','asset');
        manageRA.getFieldNames();
        Test.startTest();
        PageReference page = manageRA.saveAndNewRuleAction();
        Test.stopTest();
        system.assertEquals(page.getURL(),'/apex/WorkflowRuleActions');
    }
    
    public static testMethod void testSaveAndNewActionRelatedObjValidation(){
        WorkflowRule__c rule = new WorkflowRule__c(Name = 'Test Test Account',Object_Name__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule; 
        WorkflowRuleAction__c ruleAction = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Contact',
                                                            field_name__c='FirstName',ActionType__c='Insert Related Object',Value__c='Test');
        insert ruleAction ;
        
        WorkflowValues_for_Insert_Record__c info = new WorkflowValues_for_Insert_Record__c();
        info.Name = 'FirstName';
        info.Value__c = 'Test';
        info.Workflow_Rule_Action__c = ruleAction.Id;
        insert info;
        
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleAction);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'FirstName';
        manageRA.newRuleAction.Reference_Id__c=Userinfo.getUserId();
        manageRA.newRuleAction.Value__c='testvalue';
        manageRA.selectedRecordId = 'LastName';
        ApexPages.currentPage().getParameters().put('parentName','contact');
        manageRA.getFieldNames();
        Test.startTest();
        PageReference page = manageRA.saveAndNewRuleAction();
        Test.stopTest();
        system.assertEquals(null,page);
        
    }
    
       public static testMethod void testMergeFieldValidation(){
        WorkflowRuleAction__c ruleA = setupData();
        ruleA .Value__c='\'This is a test\'&{!Owner.Name}';
        update ruleA;
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Name';        
        manageRA.newRuleAction.Value__c='\'This is a test\'&{!Owner.Name}';
        Test.startTest();
            PageReference page = manageRA.saveRuleAction();
        Test.stopTest();
               
       
    }
    
    public static testMethod void testMergeFieldValidationFails(){
        WorkflowRuleAction__c ruleA = setupData();
        ruleA .Value__c='\'This is a test\'&';
        update ruleA;
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA );
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Name';        
        manageRA.newRuleAction.Value__c='\'This is a test\'&';
        
        Test.startTest();
            PageReference page = manageRA.saveRuleAction();
            List<ApexPages.Message> msgList = ApexPages.getMessages();         
            System.assertEquals(WorkflowRuleActionsController.MERGE_ERROR, msgList[0].getSummary());
            manageRA.newRuleAction.Value__c='\'This is a test\'&Account.Name';
            page = manageRA.saveRuleAction();
            
            manageRA.newRuleAction.Value__c='\'This is a test&Account.Name';
            page = manageRA.saveRuleAction();
        Test.stopTest();
               
        
    }
    
    @IsTest(SeeAllData=true)
    public static void tesGetTemplates(){
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
       
        Test.startTest();
            manageRA.getTemplates();
        Test.stopTest();
               
        //List<ApexPages.Message> msgList = ApexPages.getMessages();         
        //System.assertEquals(ManageRuleActions.VALUE_ERROR, msgList[0].getSummary());
  
    }
    public static testMethod void testBuildEmailOptions(){
        PageReference pageRef = Page.WorkflowRuleActions;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sendemailto','User');
        
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        
         Test.startTest();
            manageRA.buildEmailOptionsValues();
            ApexPages.currentPage().getParameters().put('sendemailto','Queue');
            manageRA.buildEmailOptionsValues();
            
            
            ApexPages.currentPage().getParameters().put('sendemailto','Chatter Groups');
            manageRA.buildEmailOptionsValues();
            
        Test.stopTest(); 
        
    }
    
    @IsTest(SeeAllData=true)
    public static void testSaveSendEmailRuleAction(){
        WorkflowRuleAction__c ruleA = setupData();
        ruleA.ActionType__c='Send Email';
        ruleA.User_Owner_Id__c=Userinfo.getUserId();
        ruleA.Email_Template__c=[Select Id FROM EmailTemplate LIMIT 1].Id;
        update ruleA;
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        manageRA.fieldType = 'Name';
        Test.startTest();
        manageRA.getTemplates();
        PageReference page = manageRA.saveRuleAction();
        Test.stopTest();
        system.assertEquals(page.getURL(),'/'+ruleA.Workflow_Rule__c);
    }
      
    public static WorkflowRuleAction__c setupData(){
    	WorkflowRule__c rule = new WorkflowRule__c(Name = 'Test Test Account',Object_Name__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule;
        WorkflowRuleAction__c ruleAction = new WorkflowRuleAction__c(Workflow_Rule__c=rule.id,action_object__c='Account',
                                                            field_name__c='Name',ActionType__c='Update Field',Value__c='Test');
        insert ruleAction ;
        return ruleAction ;
    }
        
    
   
    //JUST FOR CODE COVERAGE
    static testmethod void testshowHideValueField(){
    	PageReference pageRef = Page.WorkflowRuleActions;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sendemailto','User');
        
        WorkflowRuleAction__c ruleA = setupData();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(ruleA);
        WorkflowRuleActionsController manageRA = new WorkflowRuleActionsController(stdcon);
        
        Test.startTest();
        	manageRA.showHideValueField();
        	system.assert(!manageRA.renderValueFieldForFormula);
        	
        	manageRA.showHideValueField();
        	system.assert(manageRA.renderValueFieldForFormula);
        	
        Test.stopTest();
        
    } 
   

}