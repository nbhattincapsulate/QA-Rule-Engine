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
private class WorkflowRuleCriteriaControllerTest {
    
    
    /*
    * Method used to test the constructor
    */ 
    static testMethod void test_Constructor(){
        Test.startTest();
        System.Test.setCurrentPage(new PageReference('/apex/x'));
        ApexPages.StandardController ctrl = new ApexPages.standardController(new WorkflowRule__c(Name='Test scoring rule',Object_Name__c='account',Active__c=true,Filter_Logic__c='AND'));
        WorkflowRuleCriteriaController cls = new WorkflowRuleCriteriaController(ctrl);
        System.assertEquals(0,cls.workflowCriteriaList.size());
        Test.stopTest();
    }


    /*
    * Method used to test the OrgObjects
    */ 
    static testMethod void test_OrgObjects(){
        Test.startTest();
        System.Test.setCurrentPage(new PageReference('/apex/x'));
        ApexPages.StandardController ctrl = new ApexPages.standardController(new WorkflowRule__c(Name='Test scoring rule',Object_Name__c='account',Active__c=true,Filter_Logic__c='AND'));
        WorkflowRuleCriteriaController cls = new WorkflowRuleCriteriaController(ctrl);
        System.assertNotEquals(0,cls.getOrgObjects().size());
        Test.stopTest();
    }

    /*
    * Method used to test the show criteria method
    */ 
    static testMethod void test_showCriteria(){
        Test.startTest();
        System.Test.setCurrentPage(new PageReference('/apex/x'));
        WorkflowRuleCriteriaController cls = new WorkflowRuleCriteriaController(new ApexPages.standardController(new WorkflowRule__c(Name='Test scoring rule',Object_Name__c='account',Active__c=true,Filter_Logic__c='AND')));
        cls.showCriteria();
        System.assertEquals(1,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());
        Test.stopTest();
    }


    /*
    * Method used to test the ad criteria method
    */ 
    static testMethod void test_addCriteria(){
        Test.startTest();
        System.Test.setCurrentPage(new PageReference('/apex/x'));
        WorkflowRuleCriteriaController cls = new WorkflowRuleCriteriaController(new ApexPages.standardController(new WorkflowRule__c(Name='Test scoring rule',Object_Name__c='account',Active__c=true,Filter_Logic__c='AND')));
        cls.showCriteria();
        System.assertEquals(1,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());

        cls.addCriteria();
        System.assertEquals(2,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());
        cls.addCriteria();

        System.assertEquals(3,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());
        Test.stopTest();
    }

    /*
    * Method used to test the delete criteria method
    */ 
    static testMethod void test_deleteCriteria(){
        Test.startTest();
        System.Test.setCurrentPage(new PageReference('/apex/x'));
        WorkflowRuleCriteriaController cls = new WorkflowRuleCriteriaController(new ApexPages.standardController(new WorkflowRule__c(Name='Test scoring rule',Object_Name__c='account',Active__c=true,Filter_Logic__c='AND')));
        cls.showCriteria();
        System.assertEquals(1,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());
        
        cls.addCriteria();
        System.assertEquals(2,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());
        
        cls.addCriteria();
        System.assertEquals(3,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());

        cls.counter = 1;
        cls.deleteCriteria();
        System.assertEquals(2,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());

        cls.counter = 1;
        cls.deleteCriteria();
        System.assertEquals(1,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());
        Test.stopTest();
    }
    
    
    /*
    * Method used to test the saveworkflowRule method
    */ 
    static testMethod void test_saveworkflowRule(){
        Test.startTest();
        System.Test.setCurrentPage(new PageReference('/apex/x'));

        WorkflowRuleCriteriaController cls = new WorkflowRuleCriteriaController(new ApexPages.standardController(new WorkflowRule__c()));
        // Save the scoring rule and check the errors
        // Negative cases 
        System.assertEquals(null,cls.saveworkflowRule());
       

        // Positive  cases 
        cls = new WorkflowRuleCriteriaController(new ApexPages.standardController(new WorkflowRule__c(Name='Test scoring rule',Object_Name__c='account',Active__c=true,Filter_Logic__c='AND')));
        cls.showCriteria();
        System.assertEquals(1,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());
        
        cls.addCriteria();
        System.assertEquals(2,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());

        cls.addCriteria();
        System.assertEquals(3,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());

        cls.addCriteria();
        System.assertEquals(4,cls.workflowCriteriaList.size());
        System.assertNotEquals(0,cls.workflowCriteriaList.size());


        // Set the field name and values 
        cls.workflowCriteriaList[0].workflowRuleCriteria.criteria_object__c = 'account';
        cls.workflowCriteriaList[0].isReference();        
        cls.workflowCriteriaList[0].workflowRuleCriteria.Field_Name__c = 'rating';
        cls.workflowCriteriaList[0].workflowRuleCriteria.Field_API_Name__c = 'rating';
        cls.workflowCriteriaList[0].isReference();
        cls.workflowCriteriaList[0].workflowRuleCriteria.Operator__c = 'equals';
        cls.workflowCriteriaList[0].dataObject.put('rating','High');

        // Set the second
        cls.workflowCriteriaList[1].workflowRuleCriteria.criteria_object__c = 'case';
        cls.workflowCriteriaList[1].workflowRuleCriteria.Field_Name__c = 'status';
        cls.workflowCriteriaList[1].workflowRuleCriteria.Field_API_Name__c = 'status';
        cls.workflowCriteriaList[1].isReference();
        cls.workflowCriteriaList[1].workflowRuleCriteria.Operator__c = 'equals';
        cls.workflowCriteriaList[1].dataObject.put('status','Open');

        // Set the third
        cls.workflowCriteriaList[2].workflowRuleCriteria.criteria_object__c = 'account';
        cls.workflowCriteriaList[2].workflowRuleCriteria.Field_Name__c = 'numberofemployees';
        cls.workflowCriteriaList[2].workflowRuleCriteria.Field_API_Name__c = 'numberofemployees';
        cls.workflowCriteriaList[2].isReference();
        cls.workflowCriteriaList[2].workflowRuleCriteria.Operator__c = 'equals';
        cls.workflowCriteriaList[2].dataObject.put('numberofemployees',2000);

        // Set the fourth
        cls.workflowCriteriaList[3].workflowRuleCriteria.criteria_object__c = 'account';
        cls.workflowCriteriaList[3].workflowRuleCriteria.Field_Name__c = 'parentid';
        cls.workflowCriteriaList[3].workflowRuleCriteria.Field_API_Name__c = 'parentid';
        cls.workflowCriteriaList[3].isReference();
        cls.workflowCriteriaList[3].workflowRuleCriteria.Parent_Object_Name__c = 'account';
        cls.workflowCriteriaList[3].workflowRuleCriteria.Parent_Object_Field__c = 'rating';
        cls.workflowCriteriaList[3].setParentField();
        cls.workflowCriteriaList[3].workflowRuleCriteria.Operator__c = 'equals';
        cls.workflowCriteriaList[3].dataObject.put('rating','High');

        System.assertNotEquals(null,cls.saveworkflowRule());

        // Check the scoring rule and its criteria 
        WorkflowRule__c workflowRule = [SELECT Id, Object_Name__c, Active__c,  
                                            (SELECT Id, Field_Name__c, Field_Type__c, Operator__c, Parent_Object_Field__c, 
                                                    Parent_Object_Name__c, Value__c
                                                        FROM Workflow_Rule_Criterias__r) 
                                            FROM WorkflowRule__c LIMIT 1];

        // Check the values 
        System.assertEquals('account',workflowRule.Object_Name__c);
        System.assert(workflowRule.Active__c);
        System.assertEquals(4,workflowRule.Workflow_Rule_Criterias__r.size());

        // Call the constructor again and check the values 
        cls = new WorkflowRuleCriteriaController(new ApexPages.standardController(workflowRule));
        System.assertEquals(4,cls.workflowCriteriaList.size());

    }
}